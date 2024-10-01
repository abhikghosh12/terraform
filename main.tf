# main.tf

module "vpc" {
  source      = "./modules/vpc"
  vpc_cidr    = var.vpc_cidr
  az_count    = var.az_count
  environment = var.environment
  region      = var.aws_region
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  fargate_subnet_ids = module.vpc.private_subnet_ids

  depends_on = [module.vpc]
}

resource "time_sleep" "wait_for_eks" {
  depends_on = [module.eks]

  create_duration = "300s"
}

resource "null_resource" "wait_for_cluster" {
  depends_on = [time_sleep.wait_for_eks]

  provisioner "local-exec" {
    command = <<EOF
      until kubectl get nodes
      do
        echo "Waiting for EKS cluster to be ready..."
        sleep 10
      done
    EOF

    environment = {
      KUBECONFIG = module.eks.kubeconfig
    }
  }
}

resource "kubernetes_namespace" "voice_app" {
  depends_on = [null_resource.wait_for_cluster]

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  depends_on = [null_resource.wait_for_cluster]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<YAML
- rolearn: ${module.eks.fargate_pod_execution_role_arn}
  username: system:node:{{SessionName}}
  groups:
    - system:bootstrappers
    - system:nodes
    - system:node-proxier
YAML
  }

  force = true
}

resource "null_resource" "patch_coredns" {
  depends_on = [kubernetes_config_map_v1_data.aws_auth]

  provisioner "local-exec" {
    command = <<EOF
kubectl patch deployment coredns \
  -n kube-system \
  --type json \
  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
EOF

    environment = {
      KUBECONFIG = module.eks.kubeconfig
    }
  }
}

resource "helm_release" "voice_app" {
  depends_on = [null_resource.patch_coredns, kubernetes_namespace.voice_app]

  name       = var.release_name
  chart      = "${path.module}/Charts/voice-app-0.1.0.tgz"
  version    = var.chart_version
  namespace  = var.namespace

  values = [
    file("${path.module}/voice-app-values.yaml")
  ]

  set {
    name  = "webapp.image.tag"
    value = var.webapp_image_tag
  }

  set {
    name  = "worker.image.tag"
    value = var.worker_image_tag
  }

  set {
    name  = "webapp.replicaCount"
    value = var.webapp_replica_count
  }

  set {
    name  = "worker.replicaCount"
    value = var.worker_replica_count
  }

  set {
    name  = "ingress.enabled"
    value = var.ingress_enabled
  }

  set {
    name  = "ingress.host"
    value = var.ingress_host
  }

  set {
    name  = "persistence.uploads.enabled"
    value = "false"
  }

  set {
    name  = "persistence.output.enabled"
    value = "false"
  }
}