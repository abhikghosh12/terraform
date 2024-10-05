# modules/k8s_resources/main.tf

resource "kubernetes_namespace" "voice_app" {
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_storage_class" "efs" {
  metadata {
    name = "efs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = var.efs_id
    directoryPerms   = "700"
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }
}

resource "kubernetes_persistent_volume" "efs" {
  metadata {
    name = "efs-pv"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    volume_mode                      = "Filesystem"
    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = kubernetes_storage_class.efs.metadata[0].name
    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = var.efs_id
      }
    }
  }
  depends_on = [kubernetes_storage_class.efs]
}

resource "kubernetes_persistent_volume_claim" "uploads" {
  metadata {
    name      = "voice-app-uploads"
    namespace = kubernetes_namespace.voice_app.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs.metadata[0].name
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
  depends_on = [kubernetes_persistent_volume.efs]
}

resource "kubernetes_persistent_volume_claim" "output" {
  metadata {
    name      = "voice-app-output"
    namespace = kubernetes_namespace.voice_app.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs.metadata[0].name
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
  depends_on = [kubernetes_persistent_volume.efs]
}

output "namespace" {
  value = kubernetes_namespace.voice_app.metadata[0].name
}

output "storage_class_name" {
  value = kubernetes_storage_class.efs.metadata[0].name
}