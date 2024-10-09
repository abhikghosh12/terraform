# modules/eks/outputs.tf

output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "The name of the EKS cluster"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "The endpoint for the EKS cluster"
}

output "cluster_ca_certificate" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "The cluster CA certificate"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.eks.arn
  description = "The ARN of the OIDC Provider for EKS"
}

output "cluster_id" {
  value = aws_eks_cluster.main.id
}
