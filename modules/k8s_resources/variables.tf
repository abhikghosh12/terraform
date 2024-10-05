# modules/k8s_resources/variables.tf

variable "namespace" {
  description = "The namespace to create resources in"
  type        = string
  default     = "voice-app"
}

variable "efs_id" {
  description = "ID of the EFS file system"
  type        = string
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