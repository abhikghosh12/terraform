



module "vpc" {
  source      = "./modules/vpc"
  vpc_cidr    = var.vpc_cidr
  az_count    = var.az_count
  environment = var.environment
  create_nat_gateway = true  # Set to true if you want to create NAT Gateways
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids

 # depends_on = [module.vpc]
}

resource "time_sleep" "wait_for_eks" {
  depends_on = [module.eks]

  create_duration = "1800s"  # 30 minutes
}

resource "local_file" "kubeconfig" {
  content  = module.eks.kubeconfig
  filename = "${path.module}/kubeconfig_${var.cluster_name}"
}

resource "null_resource" "wait_for_cluster" {
  depends_on = [time_sleep.wait_for_eks, local_file.kubeconfig]

  provisioner "local-exec" {
    command = <<EOF
      for i in {1..90}; do  # 45 minutes
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

resource "kubernetes_namespace" "voice_app" {
  depends_on = [null_resource.wait_for_cluster]

  metadata {
    name = var.namespace
  }
}

resource "helm_release" "voice_app" {
  depends_on = [kubernetes_namespace.voice_app]

  name      = var.release_name
  chart     = "${path.module}/Charts/voice-app-0.1.0.tgz"
  version   = var.chart_version
  namespace = var.namespace

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



