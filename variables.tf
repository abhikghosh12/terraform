# variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
  default     = 1
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "voice-app-cluster"
}

variable "release_name" {
  description = "Helm release name for the Voice app"
  type        = string
  default     = "voice-app"
}

variable "chart_path" {
  description = "Path to the Helm chart"
  type        = string
  default     = "./voice/helm/voice"
}

variable "chart_version" {
  description = "Version of the Helm chart"
  type        = string
  default     = "0.1.0"
}

variable "namespace" {
  description = "Kubernetes namespace for the Voice app"
  type        = string
  default     = "voice-app"
}

variable "webapp_image_tag" {
  description = "Docker image tag for the webapp"
  type        = string
  default     = "latest"
}

variable "worker_image_tag" {
  description = "Docker image tag for the worker"
  type        = string
  default     = "latest"
}

variable "webapp_replica_count" {
  description = "Number of replicas for the webapp"
  type        = number
  default     = 1
}

variable "worker_replica_count" {
  description = "Number of replicas for the worker"
  type        = number
  default     = 1
}

variable "ingress_enabled" {
  description = "Enable ingress"
  type        = bool
  default     = true
}

variable "ingress_host" {
  description = "Ingress host"
  type        = string
  default     = "voice.app.com"
}

variable "domain_name" {
  description = "Domain name for external DNS"
  type        = string
  default     = "app.com"
}