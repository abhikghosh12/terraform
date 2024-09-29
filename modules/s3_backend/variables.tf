# modules/s3_backend/variables.tf

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}
