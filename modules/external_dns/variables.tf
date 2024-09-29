# modules/external_dns/variables.tf

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for external DNS"
  type        = string
}