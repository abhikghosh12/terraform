# modules/vpc/variables.tf

variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "az_count" {
  description = "az count"
  type        = number
  default       = 1
}