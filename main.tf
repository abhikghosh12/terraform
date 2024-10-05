# main.tf


module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  environment        = var.environment
  create_nat_gateway = true
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids

  depends_on = [module.vpc]
}

module "efs" {
  source               = "./modules/efs"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.cluster_security_group_id

  depends_on = [module.eks]
}

resource "time_sleep" "wait_for_eks" {
  depends_on = [module.eks]
  create_duration = "1800s"
}

resource "local_file" "kubeconfig" {
  content  = module.eks.kubeconfig
  filename = "${path.module}/kubeconfig_${var.cluster_name}"

  depends_on = [module.eks]
}

resource "null_resource" "wait_for_cluster" {
  depends_on = [time_sleep.wait_for_eks, local_file.kubeconfig]

  provisioner "local-exec" {
    command = <<EOF
      for i in {1..90}; do
        if kubectl --kubeconfig=${local_file.kubeconfig.filename} get nodes; then
          echo "Cluster is ready!"
          exit 0
        fi
        echo "Waiting for EKS cluster to be ready..."
        sleep 30
      done
      echo "Timeout waiting for EKS cluster"
      exit 1
    EOF
  }
}

resource "null_resource" "install_efs_csi_driver" {
  depends_on = [null_resource.wait_for_cluster]

  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local_file.kubeconfig.filename} apply -k \"github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.3\""
  }

  lifecycle {
    create_before_destroy = true
  }
}


module "k8s_resources" {
  source    = "./modules/k8s_resources"
  namespace = var.namespace
  efs_id    = module.efs.efs_id

  depends_on = [null_resource.install_efs_csi_driver]
}

module "voice_app" {
  source               = "./modules/voice_app"
  namespace            = module.k8s_resources.namespace
  release_name         = var.release_name
  chart_path           = "${path.root}/Charts/voice-app-0.1.0.tgz"
  chart_version        = var.chart_version
  webapp_image_tag     = var.webapp_image_tag
  worker_image_tag     = var.worker_image_tag
  webapp_replica_count = var.webapp_replica_count
  worker_replica_count = var.worker_replica_count
  ingress_enabled      = var.ingress_enabled
  ingress_host         = var.ingress_host
  storage_class_name   = module.k8s_resources.storage_class_name
  
  depends_on = [module.k8s_resources]
}

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
  environment = var.environment
}

module "external_dns" {
  source          = "./modules/external_dns"
  cluster_name    = var.cluster_name
  domain_name     = var.domain_name
  route53_zone_id = module.route53.zone_id
  eks_depends_on  = module.eks.cluster_id

  depends_on = [module.eks, module.route53]
}
