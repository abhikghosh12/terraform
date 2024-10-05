# modules/voice_app/main.tf

locals {
  # Extract the version from the chart filename
  chart_version = split("-", basename(var.chart_path))[2]
}

resource "helm_release" "voice_app" {
  name      = var.release_name
  chart     = var.chart_path
  namespace = var.namespace
  version   = trimsuffix(local.chart_version, ".tgz")

  values = [
    templatefile("${path.module}/templates/voice_app_values.yaml.tpl", {
      webapp_image_tag     = var.webapp_image_tag
      worker_image_tag     = var.worker_image_tag
      webapp_replica_count = var.webapp_replica_count
      worker_replica_count = var.worker_replica_count
      ingress_enabled      = var.ingress_enabled
      ingress_host         = var.ingress_host
      storage_class_name   = var.storage_class_name
    })
  ]

  set {
    name  = "persistence.uploads.storageClass"
    value = var.storage_class_name
  }

  set {
    name  = "persistence.output.storageClass"
    value = var.storage_class_name
  }

  lifecycle {
    ignore_changes = [
      values,
      version,
    ]
  }
}

# Add this data source if you need to fetch ingress information
data "kubernetes_ingress_v1" "voice_app" {
  metadata {
    name      = "${var.release_name}-ingress"
    namespace = var.namespace
  }

  depends_on = [helm_release.voice_app]
}









