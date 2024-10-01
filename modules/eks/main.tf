# modules/eks/main.tf
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

resource "aws_eks_fargate_profile" "main" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "voice-app-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = var.fargate_subnet_ids

  selector {
    namespace = "voice-app"
  }
}

resource "aws_eks_fargate_profile" "kube_system" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "kube-system-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution_role.arn
  subnet_ids             = var.fargate_subnet_ids

  selector {
    namespace = "kube-system"
  }
}

# IAM roles and policies for EKS cluster and Fargate profile

resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-eks-cluster-role"

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
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role" "fargate_pod_execution_role" {
  name = "${var.cluster_name}-eks-fargate-pod-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_pod_execution_role.name
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

data "aws_eks_cluster_auth" "cluster" {
     name = aws_eks_cluster.main.name
   }

   provider "kubernetes" {
     host                   = aws_eks_cluster.main.endpoint
     cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
     token                  = data.aws_eks_cluster_auth.cluster.token
   }

   resource "kubernetes_config_map_v1_data" "aws_auth" {
     metadata {
       name      = "aws-auth"
       namespace = "kube-system"
     }

     data = {
       mapRoles = <<YAML
   - rolearn: ${aws_iam_role.fargate_pod_execution_role.arn}
     username: system:node:{{SessionName}}
     groups:
       - system:bootstrappers
       - system:nodes
       - system:node-proxier
   YAML
     }

     force = true

     depends_on = [aws_eks_cluster.main]
   }

   resource "null_resource" "patch_coredns" {
     depends_on = [aws_eks_fargate_profile.kube_system]

     provisioner "local-exec" {
       command = <<EOF
   aws eks get-token --cluster-name ${aws_eks_cluster.main.name} | kubectl apply -f - && \
   kubectl patch deployment coredns \
     -n kube-system \
     --type json \
     -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
   EOF
     }
   }


resource "aws_eks_addon" "vpc_cni" {
     cluster_name = aws_eks_cluster.main.name
     addon_name   = "vpc-cni"

     resolve_conflicts = "OVERWRITE"
   }   