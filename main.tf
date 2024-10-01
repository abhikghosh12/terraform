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

resource "kubernetes_config_map_v1_data" "aws_auth" {
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

  depends_on = [module.eks]
}

resource "null_resource" "patch_coredns" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command = <<EOF
aws eks get-token --cluster-name ${module.eks.cluster_name} | kubectl apply -f - && \
kubectl patch deployment coredns \
  -n kube-system \
  --type json \
  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
EOF
  }
}

resource "helm_release" "voice_app" {
  name             = var.release_name
  chart            = "${path.module}/Charts/voice-app-0.1.0.tgz"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

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

  depends_on = [module.eks, kubernetes_config_map_v1_data.aws_auth]
}