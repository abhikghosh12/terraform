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

module "voice_app" {
  source               = "./modules/voice_app"
  cluster_name         = module.eks.cluster_name
  release_name         = var.release_name
  chart_path           = "${path.module}/Charts/voice-app-0.1.0.tgz"
  chart_version        = var.chart_version
  namespace            = var.namespace
  webapp_image_tag     = var.webapp_image_tag
  worker_image_tag     = var.worker_image_tag
  webapp_replica_count = var.webapp_replica_count
  worker_replica_count = var.worker_replica_count
  ingress_enabled      = var.ingress_enabled
  ingress_host         = var.ingress_host
  values_template_path = "${path.root}/${var.values_template_path}"

  depends_on = [module.eks]
}

# module "external_dns" {
#   source       = "./modules/external_dns"
#   cluster_name = module.eks.cluster_name
#   domain_name  = var.domain_name

#   depends_on = [module.eks]
# }

output "app_url" {
  description = "URL where the Voice App is running"
  value       = "http://${module.voice_app.ingress_hostname}"
}