output "kubeconfig" {
  value = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_name = aws_eks_cluster.main.name,
    endpoint = aws_eks_cluster.main.endpoint,
    certificate_authority_data = aws_eks_cluster.main.certificate_authority[0].data
  })
}



output "node_group_role_name" {
  value = aws_iam_role.eks_node_group_role.name
}

output "node_group_role_arn" {
  value = aws_iam_role.eks_node_group_role.arn
}


output "cluster_security_group_id" {
  value = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
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