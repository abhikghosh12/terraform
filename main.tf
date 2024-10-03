# ... (previous modules and resources)

# module "vpc" {
#   source      = "./modules/vpc"
#   vpc_cidr    = var.vpc_cidr
#   az_count    = var.az_count
#   environment = var.environment
#   create_nat_gateway = true
# }

# module "eks" {
#   source       = "./modules/eks"
#   cluster_name = var.cluster_name
#   vpc_id       = module.vpc.vpc_id
#   subnet_ids   = module.vpc.private_subnet_ids
# }

# resource "time_sleep" "wait_for_eks" {
#   depends_on = [module.eks]
#   create_duration = "1800s"
# }

# resource "local_file" "kubeconfig" {
#   content  = module.eks.kubeconfig
#   filename = "${path.module}/kubeconfig_${var.cluster_name}"
# }

# resource "null_resource" "wait_for_cluster" {
#   depends_on = [time_sleep.wait_for_eks, local_file.kubeconfig]

#   provisioner "local-exec" {
#     command = <<EOF
#       for i in {1..90}; do
#         if kubectl --kubeconfig=${local_file.kubeconfig.filename} get nodes; then
#           echo "Cluster is ready!"
#           exit 0
#         fi
#         echo "Waiting for EKS cluster to be ready..."
#         sleep 30
#       done
#       echo "Timeout waiting for EKS cluster"
#       exit 1
#     EOF
#   }
# }

module "voice_app" {
  source               = "./modules/voice-app"
  namespace            = var.namespace
  release_name         = var.release_name
  chart_path           = "${path.root}/Charts/voice-app-0.1.0.tgz"
  chart_version        = var.chart_version
  webapp_image_tag     = var.webapp_image_tag
  worker_image_tag     = var.worker_image_tag
  webapp_replica_count = var.webapp_replica_count
  worker_replica_count = var.worker_replica_count
  ingress_enabled      = var.ingress_enabled
  ingress_host         = var.ingress_host

  #depends_on = [module.eks, null_resource.wait_for_cluster]
}

