# modules/voice_app/main.tf
resource "kubernetes_namespace" "voice_app" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

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
    name  = "persistence.uploads.existingClaim"
    value = "voice-app-uploads"
  }

  set {
    name  = "persistence.output.existingClaim"
    value = "voice-app-output"
  }

  set {
    name  = "redis.master.persistence.existingClaim"
    value = "redis-master"
  }

  set {
    name  = "redis.replica.persistence.existingClaim"
    value = "redis-replicas"
  }

  depends_on = [
    kubernetes_namespace.voice_app,
    var.pvc_dependencies
  ]

  lifecycle {
    ignore_changes = [
      values,
      version,
    ]
  }
}

data "kubernetes_ingress_v1" "voice_app" {
  metadata {
    name      = "${var.release_name}-ingress"
    namespace = var.namespace
  }

  depends_on = [helm_release.voice_app]
}








