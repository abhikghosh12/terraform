# modules/efs/variables.tf

variable "vpc_id" {
  description = "ID of the VPC where EKS cluster is deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where EFS mount targets will be created"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "Security group ID of the EKS cluster"
  type        = string
}