variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "release_name" {
  description = "Name of the Helm release"
  type        = string
}

variable "chart_path" {
  description = "Path to the Helm chart"
  type        = string
}

variable "chart_version" {
  description = "Version of the Helm chart"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the Voice app"
  type        = string
}

variable "webapp_image_tag" {
  description = "Docker image tag for the webapp"
  type        = string
}

variable "worker_image_tag" {
  description = "Docker image tag for the worker"
  type        = string
}

variable "webapp_replica_count" {
  description = "Number of replicas for the webapp"
  type        = number
}

variable "worker_replica_count" {
  description = "Number of replicas for the worker"
  type        = number
}

variable "ingress_enabled" {
  description = "Enable ingress"
  type        = bool
}

variable "ingress_host" {
  description = "Ingress host"
  type        = string
}

# Add this new variable
variable "values_template_path" {
  description = "Path to the values template file"
  type        = string
}

# ... (keep all other existing variables)