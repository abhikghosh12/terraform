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

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
  default     = 3
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
  description = "Kubernetes namespace"
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
  default     = "voice.example.com"
}

variable "tf_state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "voiceapp"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}