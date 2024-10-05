# modules/k8s_resources/variables.tf

variable "efs_id" {
  description = "ID of the EFS file system"
  type        = string
}

variable "namespace" {
  description = "The namespace to create resources in"
  type        = string
  default     = "voice-app"
}