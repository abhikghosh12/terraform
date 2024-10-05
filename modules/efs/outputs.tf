# modules/efs/outputs.tf

output "efs_id" {
  value       = aws_efs_file_system.eks_efs.id
  description = "ID of the created EFS file system"
}

output "efs_dns_name" {
  value       = aws_efs_file_system.eks_efs.dns_name
  description = "DNS name of the created EFS file system"
}