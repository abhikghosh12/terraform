resource "kubernetes_namespace" "voice_app" {
  metadata {
    name = var.namespace
  }
}

# resource "helm_release" "voice_app" {
#   name       = var.release_name
#   chart      = var.chart_path
#   namespace  = kubernetes_namespace.voice_app.metadata[0].name

#   set {
#     name  = "webapp.image.tag"
#     value = var.webapp_image_tag
#   }

#   set {
#     name  = "worker.image.tag"
#     value = var.worker_image_tag
#   }

#   set {
#     name  = "webapp.replicaCount"
#     value = var.webapp_replica_count
#   }

#   set {
#     name  = "worker.replicaCount"
#     value = var.worker_replica_count
#   }

#   set {
#     name  = "ingress.enabled"
#     value = var.ingress_enabled
#   }

#   set {
#     name  = "ingress.host"
#     value = var.ingress_host
#   }

#   set {
#     name  = "debug"
#     value = "true"
#   }

#   timeout = 1800  # 30 minutes

#   depends_on = [kubernetes_namespace.voice_app]
# }


data "kubernetes_ingress_v1" "voice_app" {
  metadata {
    name      = "${var.release_name}-ingress"
    namespace = kubernetes_namespace.voice_app.metadata[0].name
  }

  depends_on = [helm_release.voice_app]
}

output "ingress_hostname" {
  description = "Hostname of the Voice App ingress"
  value       = data.kubernetes_ingress_v1.voice_app.status.0.load_balancer.0.ingress.0.hostname
}

output "helm_status" {
  value = helm_release.voice_app.status
}

output "helm_manifest" {
  value = helm_release.voice_app.manifest
}

resource "kubernetes_persistent_volume_claim" "uploads" {
     metadata {
       name      = "voice-app-uploads"
       namespace = var.namespace
     }
     spec {
       access_modes = ["ReadWriteMany"]
       resources {
         requests = {
           storage = "1Gi"
         }
       }

     }
   }

   resource "kubernetes_persistent_volume_claim" "output" {
     metadata {
       name      = "voice-app-output"
       namespace = var.namespace
     }
     spec {
       access_modes = ["ReadWriteMany"]
       resources {
         requests = {
           storage = "1Gi"
         }
       }
     }
   }

