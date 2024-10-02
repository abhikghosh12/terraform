terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = false
}