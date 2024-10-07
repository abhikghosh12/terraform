# variables.tf

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
  default     = 3
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "voice-app-cluster"
}

variable "namespace" {
  description = "Kubernetes namespace for the Voice app"
  type        = string
  default     = "voice-app"
}

variable "release_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "voice-app"
}

variable "chart_version" {
  description = "Version of the Helm chart"
  type        = string
  default     = "0.1.0"
}

variable "chart_path" {
  description = "Path to the Helm chart for the voice app"
  type        = string
  default     = "Charts/voice-app-0.1.0.tgz"
}

variable "webapp_image_tag" {
  description = "Docker image tag for the webapp"
  type        = string
  default     = "web-v1.0.3"
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

variable "uploads_storage_size" {
  description = "Size of the storage for uploads PVC"
  type        = string
  default     = "1Gi"
}

variable "output_storage_size" {
  description = "Size of the storage for output PVC"
  type        = string
  default     = "1Gi"
}