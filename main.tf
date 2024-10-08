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
  kubernetes_version = var.kubernetes_version
  depends_on = [module.vpc]
}

module "efs" {
  source      = "./modules/efs"
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
  subnet_ids  = module.vpc.private_subnet_ids
  environment = var.environment
  

  depends_on = [module.eks]
}

# ... rest of the configuration remains the same

resource "time_sleep" "wait_for_eks" {
  depends_on = [module.eks]
  create_duration = "1800s"
}

resource "null_resource" "wait_for_cluster" {
  depends_on = [time_sleep.wait_for_eks]

  provisioner "local-exec" {
    command = <<EOF
      for i in {1..90}; do
        if aws eks get-token --cluster-name ${var.cluster_name} | kubectl get nodes; then
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
    command = <<EOF
      eksctl create iamserviceaccount \
        --cluster=${var.cluster_name} \
        --namespace=kube-system \
        --name=efs-csi-controller-sa \
        --role-name=EFS-CSI-DriverRole \
        --role-only \
        --attach-policy-arn=arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
        --approve

      helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
      helm repo update
      helm upgrade --install aws-efs-csi-driver --namespace kube-system aws-efs-csi-driver/aws-efs-csi-driver
    EOF
  }

  lifecycle {
    create_before_destroy = true
  }
}

module "k8s_resources" {
  source               = "./modules/k8s_resources"
  namespace            = var.namespace
  efs_id               = module.efs.efs_id
  uploads_storage_size = var.uploads_storage_size
  output_storage_size  = var.output_storage_size

  depends_on = [null_resource.install_efs_csi_driver]
}

module "voice_app" {
  source               = "./modules/voice_app"
  namespace            = var.namespace
  create_namespace     = true
  release_name         = var.release_name
  chart_path           = "${path.root}/${var.chart_path}"
  chart_version        = var.chart_version
  webapp_image_tag     = var.webapp_image_tag
  worker_image_tag     = var.worker_image_tag
  webapp_replica_count = var.webapp_replica_count
  worker_replica_count = var.worker_replica_count
  ingress_enabled      = var.ingress_enabled
  ingress_host         = var.ingress_host
  storage_class_name   = "efs-sc"
  pvc_dependencies     = module.k8s_resources.pvc_names

  depends_on = [module.k8s_resources]
}