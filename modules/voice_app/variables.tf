# modules/voice_app/variables.tf

variable "namespace" {
  description = "Kubernetes namespace for the voice app"
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
  description = "Whether to enable ingress in the Helm chart"
  type        = bool
}

variable "create_ingress" {
  description = "Whether to create the Kubernetes Ingress resource"
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

variable "uploads_storage_size" {
  description = "Storage size for uploads PVC"
  type        = string
}

variable "output_storage_size" {
  description = "Storage size for output PVC"
  type        = string
}

variable "redis_master_storage_size" {
  description = "Storage size for Redis master PVC"
  type        = string
}

variable "redis_replicas_storage_size" {
  description = "Storage size for Redis replicas PVC"
  type        = string
}