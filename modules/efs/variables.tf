# modules/efs/variables.tf

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets where EFS mount targets will be created"
  type        = list(string)
}