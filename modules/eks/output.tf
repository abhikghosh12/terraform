

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
  value = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "kubeconfig" {
  value = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.main.endpoint}
    certificate-authority-data: ${aws_eks_cluster.main.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${aws_eks_cluster.main.name}"
KUBECONFIG
}

output "node_group_arn" {
  value = aws_eks_node_group.main.arn
}