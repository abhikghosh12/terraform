# modules/eks/outputs.tf

output "cluster_security_group_id" {
  value = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "node_group_role_name" {
  value = aws_iam_role.eks_nodes.name
}

output "node_group_role_arn" {
  value = aws_iam_role.eks_nodes.arn
}

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

data "aws_elb_hosted_zone_id" "main" {}

data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [aws_eks_cluster.main]
}

output "load_balancer_dns_name" {
  value = data.kubernetes_service.nginx_ingress.status.0.load_balancer.0.ingress.0.hostname
  description = "The DNS name of the load balancer for the NGINX Ingress Controller"
}

output "load_balancer_zone_id" {
  value = data.aws_elb_hosted_zone_id.main.id
  description = "The zone ID of the load balancer for the NGINX Ingress Controller"
}