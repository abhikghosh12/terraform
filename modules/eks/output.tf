output "cluster_name" {
  value = length(data.aws_eks_cluster.existing) > 0 ? data.aws_eks_cluster.existing[0].name : aws_eks_cluster.main[0].name
}

output "cluster_endpoint" {
  value = length(data.aws_eks_cluster.existing) > 0 ? data.aws_eks_cluster.existing[0].endpoint : aws_eks_cluster.main[0].endpoint
}

output "cluster_ca_certificate" {
  value = length(data.aws_eks_cluster.existing) > 0 ? data.aws_eks_cluster.existing[0].certificate_authority[0].data : aws_eks_cluster.main[0].certificate_authority[0].data
}

output "cluster_security_group_id" {
  value = length(data.aws_eks_cluster.existing) > 0 ? data.aws_eks_cluster.existing[0].vpc_config[0].cluster_security_group_id : aws_eks_cluster.main[0].vpc_config[0].cluster_security_group_id
}

output "kubeconfig" {
  value = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_name = length(data.aws_eks_cluster.existing) > 0 ? data.aws_eks_cluster.existing[0].name : aws_eks_cluster.main[0].name,
    endpoint = length(data.aws_eks_cluster.existing) > 0 ? data.aws_eks_cluster.existing[0].endpoint : aws_eks_cluster.main[0].endpoint,
    certificate_authority_data = length(data.aws_eks_cluster.existing) > 0 ? data.aws_eks_cluster.existing[0].certificate_authority[0].data : aws_eks_cluster.main[0].certificate_authority[0].data
  })
}