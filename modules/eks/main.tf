# modules/eks/main.tf

module "iam" {
  source       = "../iam"
  cluster_name = var.cluster_name
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = module.iam.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = merge(
    {
      "Name" = var.cluster_name
    },
    var.tags
  )

  depends_on = [
    module.iam
  ]
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.node_group_name
  node_role_arn   = module.iam.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types

  tags = merge(
    {
      "Name" = var.node_group_name
    },
    var.tags
  )

  depends_on = [
    module.iam
  ]
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}