# modules/route53/variables.tf

variable "domain_name" {
  description = "The domain name for the Route 53 hosted zone"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., prod, staging, dev)"
  type        = string
}
