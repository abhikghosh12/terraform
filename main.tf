# main.tf
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  environment        = var.environment
  create_nat_gateway = true
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  kubernetes_version = var.kubernetes_version
  depends_on         = [module.vpc]
}

module "efs" {
  source            = "./modules/efs"
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = var.vpc_cidr
  subnet_ids        = module.vpc.private_subnet_ids
  environment       = var.environment
  cluster_name      = module.eks.cluster_name  # Use the output from EKS module
  oidc_provider_arn = module.eks.oidc_provider_arn  # Use the output from EKS module
  depends_on        = [module.eks]
}

resource "time_sleep" "wait_for_eks" {
  depends_on      = [module.eks]
  create_duration = "1800s"
}

resource "null_resource" "wait_for_cluster" {
  depends_on = [time_sleep.wait_for_eks]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
      for i in {1..90}; do
        CLUSTER_STATUS=$(aws eks describe-cluster --name ${var.cluster_name} --query 'cluster.status' --output text)
        if [ "$CLUSTER_STATUS" = "ACTIVE" ]; then
          echo "Cluster is active, checking for nodes..."
          
          NODE_COUNT=$(aws eks list-nodegroups --cluster-name ${var.cluster_name} --query 'length(nodegroups)' --output text)
          
          if [ "$NODE_COUNT" -gt 0 ]; then
            READY_NODES=$(aws eks list-nodegroups --cluster-name ${var.cluster_name} --query 'nodegroups[0]' --output text | xargs -I {} aws eks describe-nodegroup --cluster-name ${var.cluster_name} --nodegroup-name {} --query 'nodegroup.status' --output text)
            
            if [ "$READY_NODES" = "ACTIVE" ]; then
              echo "Nodes are ready. Cluster is fully operational!"
              exit 0
            fi
          fi
        fi
        echo "Waiting for EKS cluster to be ready... (Attempt $i/90)"
        sleep 30
      done
      echo "Timeout waiting for EKS cluster"
      exit 1
    EOF
  }
}

module "k8s_resources" {
  source               = "./modules/k8s_resources"
  namespace            = var.namespace
  efs_id               = module.efs.efs_id
  uploads_storage_size       = var.uploads_storage_size
  output_storage_size        = var.output_storage_size


  depends_on = [module.efs]
}

module "voice_app" {
  source                      = "./modules/voice_app"
  namespace                   = var.namespace
  release_name                = var.release_name
  chart_path                  = "${path.root}/${var.chart_path}"
  chart_version               = var.chart_version
  webapp_image_tag            = var.webapp_image_tag
  worker_image_tag            = var.worker_image_tag
  webapp_replica_count        = var.webapp_replica_count
  worker_replica_count        = var.worker_replica_count
  ingress_enabled             = var.ingress_enabled
  ingress_host                = var.domain_name  # Use domain_name here
  storage_class_name          = "efs-sc"
  uploads_storage_size        = var.uploads_storage_size
  output_storage_size         = var.output_storage_size
  redis_master_storage_size   = "1Gi"
  redis_replicas_storage_size = "1Gi"

  depends_on = [module.k8s_resources]
}

resource "local_file" "kubeconfig" {
  depends_on = [null_resource.wait_for_cluster]
  filename   = "${path.root}/kubeconfig_${var.cluster_name}"
  content = templatefile(
    "${path.root}/modules/eks/kubeconfig.tpl",
    {
      cluster_name               = var.cluster_name
      endpoint                   = module.eks.cluster_endpoint
      certificate_authority_data = module.eks.cluster_ca_certificate
    }
  )
}

module "external_dns" {
  source          = "./modules/external_dns"
  cluster_name    = var.cluster_name
  domain_name     = var.domain_name
  route53_zone_id = module.route53.zone_id
  eks_depends_on  = module.eks.cluster_id

  depends_on = [module.eks, module.route53]
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }

  depends_on = [module.eks, null_resource.wait_for_cluster]
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  version    = "4.7.1"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
  }

  depends_on = [module.eks, kubernetes_namespace.ingress_nginx]
}

data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "${helm_release.nginx_ingress.name}-ingress-nginx-controller"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  depends_on = [helm_release.nginx_ingress]
}

data "aws_elb_hosted_zone_id" "main" {}

# Add a time_sleep resource to allow time for the load balancer to be created
resource "time_sleep" "wait_for_loadbalancer" {
  depends_on = [helm_release.nginx_ingress]
  create_duration = "900s"
}

module "route53" {
  source                 = "./modules/route53"
  domain_name            = "voicesapp.net"
  environment            = var.environment
  load_balancer_dns_name = data.kubernetes_service.nginx_ingress.status.0.load_balancer.0.ingress.0.hostname
  load_balancer_zone_id  = data.aws_elb_hosted_zone_id.main.id

  depends_on = [time_sleep.wait_for_loadbalancer]
}
