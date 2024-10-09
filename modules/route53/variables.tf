# modules/route53/variables.tf

variable "domain_name" {
  type        = string
  description = "The domain name for the Route53 zone"
}

variable "environment" {
  type        = string
  description = "The environment (e.g., production, staging)"
}

variable "load_balancer_dns_name" {
  type        = string
  description = "DNS name of the load balancer"
}

variable "load_balancer_zone_id" {
  type        = string
  description = "Zone ID of the load balancer"
}
