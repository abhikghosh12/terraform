# modules/eks/main.tf# modules/eks/main.tf

locals {
  eks_cluster_role_name = "${var.cluster_name}-eks-cluster-role"
  eks_node_group_role_name = "${var.cluster_name}-eks-node-group-role"
}

resource "aws_iam_role" "eks_cluster" {
  name = local.eks_cluster_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
  lifecycle {
    ignore_changes = [assume_role_policy]
  }
}

resource "aws_iam_role" "eks_node_group" {

  name = local.eks_node_group_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  lifecycle {
    ignore_changes = [assume_role_policy]
  }
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = length(data.aws_iam_role.existing_cluster_role) > 0 ? data.aws_iam_role.existing_cluster_role[0].arn : aws_iam_role.eks_cluster[0].arn
  version  = "1.31"
  vpc_config {
    subnet_ids = var.subnet_ids
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = length(data.aws_iam_role.existing_cluster_role) > 0 ? data.aws_iam_role.existing_cluster_role[0].name : aws_iam_role.eks_cluster[0].name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = length(data.aws_iam_role.existing_cluster_role) > 0 ? data.aws_iam_role.existing_cluster_role[0].name : aws_iam_role.eks_cluster[0].name
}

resource "aws_eks_node_group" "main" {
  cluster_name    = length(data.aws_eks_cluster.existing) > 0 ? data.aws_eks_cluster.existing[0].name : aws_eks_cluster.main[0].name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = length(data.aws_iam_role.existing_node_group_role) > 0 ? data.aws_iam_role.existing_node_group_role[0].arn : aws_iam_role.eks_node_group[0].arn
  subnet_ids      = var.subnet_ids
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t3.medium"]
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry,
  ]
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = length(data.aws_iam_role.existing_node_group_role) > 0 ? data.aws_iam_role.existing_node_group_role[0].name : aws_iam_role.eks_node_group[0].name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = length(data.aws_iam_role.existing_node_group_role) > 0 ? data.aws_iam_role.existing_node_group_role[0].name : aws_iam_role.eks_node_group[0].name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = length(data.aws_iam_role.existing_node_group_role) > 0 ? data.aws_iam_role.existing_node_group_role[0].name : aws_iam_role.eks_node_group[0].name
}



