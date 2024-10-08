# modules/voice_app/variables.tf

variable "release_name" {
  description = "Name of the Helm release"
  type        = string
}

variable "chart_path" {
  description = "Path to the Helm chart"
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
  description = "Whether to enable ingress"
  type        = bool
}

variable "ingress_host" {
  description = "Hostname for the ingress"
  type        = string
}

variable "storage_class_name" {
  description = "Name of the storage class to use"
  type        = string
}

variable "chart_version" {
  description = "Version of the Helm chart"
  type        = string
  default     = "0.1.0"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}

variable "pvc_dependencies" {
  description = "List of PVC names that should exist before deploying the voice app"
  type        = list(string)
}


# modules/voice_app/variables.tf

# ... (existing variables)

variable "uploads_storage_size" {
  description = "Storage size for uploads PVC"
  type        = string
  default     = "1Gi"
}

variable "output_storage_size" {
  description = "Storage size for output PVC"
  type        = string
  default     = "1Gi"
}

variable "redis_master_storage_size" {
  description = "Storage size for Redis master PVC"
  type        = string
  default     = "1Gi"
}

variable "redis_replicas_storage_size" {
  description = "Storage size for Redis replicas PVC"
  type        = string
  default     = "1Gi"
}