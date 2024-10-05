# modules/external_dns/variables.tf

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for external DNS"
  type        = string
}

variable "eks_depends_on" {
  description = "Value that external-dns depends on"
  type        = any
  default     = null
}

variable "route53_zone_id" {
  description = "The Route 53 zone ID to use for external-dns"
  type        = string
}