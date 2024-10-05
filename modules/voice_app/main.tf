# modules/voice_app/main.tf

resource "helm_release" "voice_app" {
  name      = var.release_name
  chart     = var.chart_path
  namespace = var.namespace
  version   = var.chart_version

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

output "helm_release_id" {
  value = helm_release.voice_app.id
  description = "The ID of the Helm release for the voice app"
}








