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
    volume_name = var.pv_names["voice-app-uploads"]
  }
  lifecycle {
    ignore_changes = [
      metadata,
      spec["resources"],
    ]
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
    volume_name = var.pv_names["voice-app-output"]
  }
  lifecycle {
    ignore_changes = [
      metadata,
      spec["resources"],
    ]
  }

}

resource "kubernetes_persistent_volume_claim" "redis_master" {
  metadata {
    name      = "redis-master"
    namespace = var.namespace
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.redis_master_storage_size
      }
    }
    volume_name = var.pv_names["redis-master"]
  }
  lifecycle {
    ignore_changes = [
      metadata,
      spec["resources"],
    ]
  }

}

resource "kubernetes_persistent_volume_claim" "redis_replicas" {
  metadata {
    name      = "redis-replicas"
    namespace = var.namespace
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.redis_replicas_storage_size
      }
    }
    volume_name = var.pv_names["redis-replicas"]
  }
  lifecycle {
    ignore_changes = [
      metadata,
      spec["resources"],
    ]
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
    value = "true"
  }
  set {
    name  = "persistence.uploads.storageClassName"
    value = var.storage_class_name
  }
  set {
    name  = "persistence.uploads.size"
    value = var.uploads_storage_size
  }

  set {
    name  = "persistence.output.enabled"
    value = "true"
  }
  set {
    name  = "persistence.output.storageClassName"
    value = var.storage_class_name
  }
  set {
    name  = "persistence.output.size"
    value = var.output_storage_size
  }

  set {
    name  = "redis.master.persistence.enabled"
    value = "true"
  }
  set {
    name  = "redis.master.persistence.storageClass"
    value = var.storage_class_name
  }
  set {
    name  = "redis.master.persistence.size"
    value = var.redis_master_storage_size
  }

  set {
    name  = "redis.replica.persistence.enabled"
    value = "true"
  }
  set {
    name  = "redis.replica.persistence.storageClass"
    value = var.storage_class_name
  }
  set {
    name  = "redis.replica.persistence.size"
    value = var.redis_replicas_storage_size
  }

  set {
    name  = "ingress.enabled"
    value = var.ingress_enabled
  }

  set {
    name  = "ingress.host"
    value = var.ingress_host
  }

# Keep the kubernetes_ingress_v1 resource as is
  
  depends_on = [
    kubernetes_persistent_volume_claim.voice_app_uploads,
    kubernetes_persistent_volume_claim.voice_app_output,
    kubernetes_persistent_volume_claim.redis_master,
    kubernetes_persistent_volume_claim.redis_replicas,
  ]
}

resource "kubernetes_ingress_v1" "voice_app" {
  count = var.create_ingress ? 1 : 0

  metadata {
    name      = "voice-app-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect"    = "false"
      "nginx.ingress.kubernetes.io/use-regex"       = "true"
      "nginx.ingress.kubernetes.io/rewrite-target"  = "/$1"
      "nginx.ingress.kubernetes.io/configuration-snippet" = "proxy_set_header Access-Control-Allow-Origin \"*\";"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.ingress_host
      http {
        path {
          path      = "/(.*)"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "${var.release_name}-voice-app"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      http {
        path {
          path      = "/(.*)"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "${var.release_name}-voice-app"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.voice_app]
}