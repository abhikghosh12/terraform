# modules/eks/main.tf

locals {
  eks_cluster_role_name = "${var.cluster_name}-eks-cluster-role"
  eks_node_group_role_name = "${var.cluster_name}-eks-node-group-role"
}

# Always create the cluster IAM role
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

# Always create the node group IAM role
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

locals {
  eks_cluster_role_arn = coalesce(try(data.aws_iam_role.existing_eks_cluster[0].arn, ""), aws_iam_role.eks_cluster.arn)
  eks_node_group_role_arn = coalesce(try(data.aws_iam_role.existing_eks_node_group[0].arn, ""), aws_iam_role.eks_node_group.arn)
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

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = split("/", local.eks_cluster_role_arn)[1]
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = split("/", local.eks_cluster_role_arn)[1]
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
  role       = split("/", local.eks_node_group_role_arn)[1]
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = split("/", local.eks_node_group_role_arn)[1]
}

resource "aws_iam_role_policy_attachment" "eks_container_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = split("/", local.eks_node_group_role_arn)[1]
}

# ... rest of the file remains the same ...

