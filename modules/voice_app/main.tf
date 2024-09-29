# modules/voice_app/main.tf

resource "local_file" "helm_values" {
  content = templatefile("${path.root}/templates/voice_app_values.yaml.tpl", {
    webapp_image_tag     = var.webapp_image_tag
    webapp_replica_count = var.webapp_replica_count
    worker_image_tag     = var.worker_image_tag
    worker_replica_count = var.worker_replica_count
    ingress_enabled      = var.ingress_enabled
    ingress_host         = var.ingress_host
  })
  filename = "${path.module}/generated_values.yaml"
}

resource "helm_release" "voice_app" {
  name       = var.release_name
  chart      = var.chart_path
  version    = var.chart_version
  namespace  = var.namespace

  values = [
    local_file.helm_values.content
  ]

  depends_on = [local_file.helm_values]
}

# modules/voice_app/variables.tf

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
  description = "Kubernetes namespace"
  type        = string
}

variable "webapp_image_tag" {
  description = "Docker image tag for the webapp"
  type        = string
}

variable "webapp_replica_count" {
  description = "Number of replicas for the webapp"
  type        = number
}

variable "worker_image_tag" {
  description = "Docker image tag for the worker"
  type        = string
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

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

