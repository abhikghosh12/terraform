# variables.tf

# Existing variables
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

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "voice-app-cluster"
}

variable "node_group_name" {
  description = "EKS node group name"
  type        = string
  default     = "voice-app-nodes"
}

variable "instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}

variable "namespace" {
  description = "Kubernetes namespace for the Voice app"
  type        = string
  default     = "voice-app"
}

variable "release_name" {
  description = "Helm release name for the Voice app"
  type        = string
  default     = "voice-app"
}

variable "chart_version" {
  description = "Helm chart version for the Voice app"
  type        = string
  default     = "1.0.0"
}

variable "domain_name" {
  description = "Domain name for external DNS"
  type        = string
  default     = "voice.example.com"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.24"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# New variables
variable "webapp_image_tag" {
  description = "Docker image tag for the webapp"
  type        = string
  default     = "webapp-v1.0.3"
}

variable "worker_image_tag" {
  description = "Docker image tag for the worker"
  type        = string
  default     = "worker-v1.0.3"
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

variable "chart_path" {
  description = "Path to the Helm chart"
  type        = string
  default     = "./voice/helm/voice"
}