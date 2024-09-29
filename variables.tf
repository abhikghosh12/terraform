# variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
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

variable "values_file" {
  description = "Path to the Helm values file"
  type        = string
  default     = "voice-app-values.yaml"
}

variable "domain_name" {
  description = "Domain name for external DNS"
  type        = string
  default     = "voice.example.com"
}  

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.24"  # You can set a default version or remove this line to require explicit setting
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}