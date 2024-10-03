output "voice_app_ingress_hostname" {
  value = module.voice_app.ingress_hostname
}

output "voice_app_helm_status" {
  value = module.voice_app.helm_status
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

# output "kubeconfig_path" {
#   description = "Path to kubeconfig file"
#   value       = local_file.kubeconfig.filename
# }