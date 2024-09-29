# modules/voice_app/variables.tf

variable "release_name" {
  description = "Name of the Helm release"
  type        = string
}

variable "chart_version" {
  description = "Version of the Helm chart to deploy"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace to deploy the Helm chart into"
  type        = string
}

variable "values_file" {
  description = "Path to the values file for the Helm chart"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "replica_count" {
  description = "Number of replicas for the Voice app"
  type        = number
  default     = 1
}
# Add more variables as needed for your Voice app configuration
