# modules/k8s_resources/variables.tf

variable "namespace" {
  description = "The namespace to create resources in"
  type        = string
}

variable "efs_id" {
  description = "ID of the EFS file system"
  type        = string
}

variable "uploads_storage_size" {
  description = "Size of the storage for uploads PV and PVC"
  type        = string
  default     = "5Gi"
}

variable "output_storage_size" {
  description = "Size of the storage for output PV and PVC"
  type        = string
  default     = "5Gi"
}

