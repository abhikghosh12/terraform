# modules/voice_app/main.tf

resource "kubernetes_persistent_volume_claim" "voice_app_uploads" {
  metadata {
    name      = "voice-app-uploads"
    namespace = var.namespace
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.uploads_storage_size
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "voice_app_output" {
  metadata {
    name      = "voice-app-output"
    namespace = var.namespace
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.output_storage_size
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "redis_master" {
  metadata {
    name      = "redis-master"
    namespace = var.namespace
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.redis_master_storage_size
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "redis_replicas" {
  metadata {
    name      = "redis-replicas"
    namespace = var.namespace
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.redis_replicas_storage_size
      }
    }
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
    name  = "persistence.uploads.enabled"
    value = "false"
  }

  set {
    name  = "persistence.output.enabled"
    value = "false"
  }

  set {
    name  = "redis.master.persistence.enabled"
    value = "false"
  }

  set {
    name  = "redis.replica.persistence.enabled"
    value = "false"
  }

  set {
    name  = "persistence.uploads.existingClaim"
    value = kubernetes_persistent_volume_claim.voice_app_uploads.metadata[0].name
  }

  set {
    name  = "persistence.output.existingClaim"
    value = kubernetes_persistent_volume_claim.voice_app_output.metadata[0].name
  }

  set {
    name  = "redis.master.persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.redis_master.metadata[0].name
  }

  set {
    name  = "redis.replica.persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.redis_replicas.metadata[0].name
  }

  set {
    name  = "ingress.enabled"
    value = var.ingress_enabled
  }

  set {
    name  = "ingress.host"
    value = var.ingress_host
  }
  
  depends_on = [
    kubernetes_persistent_volume_claim.voice_app_uploads,
    kubernetes_persistent_volume_claim.voice_app_output,
    kubernetes_persistent_volume_claim.redis_master,
    kubernetes_persistent_volume_claim.redis_replicas,
  ]

  lifecycle {
    ignore_changes = [
      values,
      version,
      set,
    ]
  }
}

resource "kubernetes_ingress_v1" "voice_app" {
  metadata {
    name      = "voice-app-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
    }
  }

  spec {
    rule {
      host = var.ingress_host
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "voice-app-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = all
  }
}

# ... (rest of the file remains unchanged)