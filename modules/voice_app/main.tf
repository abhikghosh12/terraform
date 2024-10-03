resource "kubernetes_namespace" "voice_app" {
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = all
  }
}

data "kubernetes_storage_class" "gp2" {
  metadata {
    name = "gp2"
  }
}

resource "helm_release" "voice_app" {
  name       = var.release_name
  chart      = var.chart_path
  namespace  = kubernetes_namespace.voice_app.metadata[0].name
  version    = var.chart_version

  values = [
    templatefile("${path.root}/templates/voice_app_values.yaml.tpl", {
      webapp_image_tag     = var.webapp_image_tag
      worker_image_tag     = var.worker_image_tag
      webapp_replica_count = var.webapp_replica_count
      worker_replica_count = var.worker_replica_count
      ingress_enabled      = var.ingress_enabled
      ingress_host         = var.ingress_host
      uploads_pvc_name     = "voice-app-uploads"
      output_pvc_name      = "voice-app-output"
    })
  ]

  depends_on = [
    kubernetes_namespace.voice_app
  ]

  lifecycle {
    ignore_changes = [
      values,
      version,
    ]
  }
}

# resource "kubernetes_persistent_volume_claim" "uploads" {
#   metadata {
#     name      = "voice-app-uploads"
#     namespace = kubernetes_namespace.voice_app.metadata[0].name
#   }
#   spec {
#     access_modes = ["ReadWriteMany"]
#     storage_class_name = data.kubernetes_storage_class.gp2.metadata[0].name
#     resources {
#       requests = {
#         storage = "1Gi"
#       }
#     }
#   }

#   lifecycle {
#     ignore_changes = [
#       metadata[0].annotations,
#       metadata[0].labels,
#       spec[0].volume_name,
#     ]
#   }

#   timeouts {
#     create = "10m"
#     update = "10m"
#   }


# }

# resource "kubernetes_persistent_volume_claim" "output" {
#   metadata {
#     name      = "voice-app-output"
#     namespace = kubernetes_namespace.voice_app.metadata[0].name
#   }
#   spec {
#     access_modes = ["ReadWriteMany"]
#     storage_class_name = data.kubernetes_storage_class.gp2.metadata[0].name
#     resources {
#       requests = {
#         storage = "1Gi"
#       }
#     }
#   }

#   lifecycle {
#     ignore_changes = [
#       metadata[0].annotations,
#       metadata[0].labels,
#       spec[0].volume_name,
#     ]
#   }

#   timeouts {
#     create = "10m"
#     update = "10m"
#   }


# }

data "kubernetes_ingress_v1" "voice_app" {
  metadata {
    name      = "${var.release_name}-ingress"
    namespace = kubernetes_namespace.voice_app.metadata[0].name
  }

  depends_on = [helm_release.voice_app]
}




