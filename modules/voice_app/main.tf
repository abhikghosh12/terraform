resource "kubernetes_namespace" "voice_app" {
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = all
  }
}

data "kubernetes_storage_class" "efs-sc" {
  metadata {
    name = "efs-sc"
  }
}

resource "null_resource" "helm_starter" {
  triggers = {
    chart_version = var.chart_version
    values_hash   = sha256(templatefile("${path.root}/templates/voice_app_values.yaml.tpl", {
      webapp_image_tag     = var.webapp_image_tag
      worker_image_tag     = var.worker_image_tag
      webapp_replica_count = var.webapp_replica_count
      worker_replica_count = var.worker_replica_count
      ingress_enabled      = var.ingress_enabled
      ingress_host         = var.ingress_host
      uploads_pvc_name     = "voice-app-uploads"
      output_pvc_name      = "voice-app-output"
    }))
  }

  provisioner "local-exec" {
    command = <<EOT
      helm upgrade --install ${var.release_name} ${var.chart_path} \
        --namespace ${kubernetes_namespace.voice_app.metadata[0].name} \
        --version ${var.chart_version} \
        --values ${path.root}/templates/voice_app_values.yaml.tpl \
        --set webapp.image.tag=${var.webapp_image_tag} \
        --set worker.image.tag=${var.worker_image_tag} \
        --set webapp.replicaCount=${var.webapp_replica_count} \
        --set worker.replicaCount=${var.worker_replica_count} \
        --set ingress.enabled=${var.ingress_enabled} \
        --set ingress.host=${var.ingress_host} \
        --wait --timeout 10m
    EOT
  }


}

resource "kubernetes_persistent_volume_claim" "uploads" {
  metadata {
    name      = "voice-app-uploads"
    namespace = kubernetes_namespace.voice_app.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = data.kubernetes_storage_class.gp2.metadata[0].name
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
      spec[0].volume_name,
    ]
  }

  timeouts {
    create = "10m"

  }

  depends_on = [null_resource.helm_starter]
}

resource "kubernetes_persistent_volume_claim" "output" {
  metadata {
    name      = "voice-app-output"
    namespace = kubernetes_namespace.voice_app.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = data.kubernetes_storage_class.gp2.metadata[0].name
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
      spec[0].volume_name,
    ]
  }

  timeouts {
    create = "10m"

  }

  depends_on = [null_resource.helm_starter]
}

resource "null_resource" "helm_waiter" {
  provisioner "local-exec" {
    command = "helm status ${var.release_name} --namespace ${kubernetes_namespace.voice_app.metadata[0].name}"
  }

  depends_on = [
    null_resource.helm_starter,
    kubernetes_persistent_volume_claim.uploads,
    kubernetes_persistent_volume_claim.output
  ]
}

data "kubernetes_ingress_v1" "voice_app" {
  metadata {
    name      = "${var.release_name}-ingress"
    namespace = kubernetes_namespace.voice_app.metadata[0].name
  }

  depends_on = [null_resource.helm_waiter]
}

output "ingress_hostname" {
  description = "Hostname of the Voice App ingress"
  value       = try(data.kubernetes_ingress_v1.voice_app.status[0].load_balancer[0].ingress[0].hostname, "")
}

output "helm_status" {
  value = null_resource.helm_waiter.id != "" ? "Completed" : "Failed"
}





