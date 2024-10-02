# modules/eks/main.tf

# Check if the cluster IAM role already exists
data "aws_iam_role" "existing_eks_cluster" {
  name = "${var.cluster_name}-eks-cluster-role"
  count = 1
}

locals {
  eks_cluster_role_arn = length(data.aws_iam_role.existing_eks_cluster) > 0 ? data.aws_iam_role.existing_eks_cluster[0].arn : aws_iam_role.eks_cluster[0].arn
  eks_cluster_role_name = length(data.aws_iam_role.existing_eks_cluster) > 0 ? data.aws_iam_role.existing_eks_cluster[0].name : aws_iam_role.eks_cluster[0].name
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = local.eks_cluster_role_arn
  version  = "1.31"

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

# Only create the cluster IAM role if it doesn't already exist
resource "aws_iam_role" "eks_cluster" {
  count = length(data.aws_iam_role.existing_eks_cluster) == 0 ? 1 : 0
  name  = "${var.cluster_name}-eks-cluster-role"

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
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = local.eks_cluster_role_name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = local.eks_cluster_role_name
}

# Check if the node group IAM role already exists
data "aws_iam_role" "existing_eks_node_group" {
  name = "${var.cluster_name}-eks-node-group-role"
  count = 1
}

locals {
  eks_node_group_role_arn = length(data.aws_iam_role.existing_eks_node_group) > 0 ? data.aws_iam_role.existing_eks_node_group[0].arn : aws_iam_role.eks_node_group[0].arn
  eks_node_group_role_name = length(data.aws_iam_role.existing_eks_node_group) > 0 ? data.aws_iam_role.existing_eks_node_group[0].name : aws_iam_role.eks_node_group[0].name
}

# Only create the node group IAM role if it doesn't already exist
resource "aws_iam_role" "eks_node_group" {
  count = length(data.aws_iam_role.existing_eks_node_group) == 0 ? 1 : 0
  name  = "${var.cluster_name}-eks-node-group-role"

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
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = local.eks_node_group_role_arn
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
  role       = local.eks_node_group_role_name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = local.eks_node_group_role_name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = local.eks_node_group_role_name
}

# ... rest of the file remains the same ...
