# main.tf

module "vpc" {
  source      = "./modules/vpc"
  region      = var.aws_region
  environment = var.environment
  az_count    = var.az_count
  vpc_cidr    = var.vpc_cidr
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  node_group_name     = var.node_group_name
  instance_types      = var.instance_types
  desired_size        = var.desired_size
  min_size            = var.min_size
  max_size            = var.max_size
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  depends_on = [module.vpc]
}

module "voice_app" {
  source               = "./modules/voice_app"
  release_name         = var.release_name
  chart_path           = var.chart_path
  chart_version        = var.chart_version
  namespace            = var.namespace
  webapp_image_tag     = var.webapp_image_tag
  worker_image_tag     = var.worker_image_tag
  webapp_replica_count = var.webapp_replica_count
  worker_replica_count = var.worker_replica_count
  ingress_enabled      = var.ingress_enabled
  ingress_host         = var.ingress_host
  cluster_name         = module.eks.cluster_name

  depends_on = [module.eks]
}

module "external_dns" {
  source       = "./modules/external_dns"
  cluster_name = module.eks.cluster_name
  domain_name  = var.domain_name

  depends_on = [module.eks]
}

module "s3_backend" {
  source      = "./modules/s3_backend"
  bucket_name = var.tf_state_bucket_name
}
