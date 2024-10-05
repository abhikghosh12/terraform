# modules/k8s_resources/main.tf

resource "kubernetes_storage_class" "efs" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = var.efs_id
    directoryPerms   = "700"
  }
}

resource "kubernetes_persistent_volume" "uploads" {
  metadata {
    name = "voice-app-uploads-pv"
  }
  spec {
    capacity = {
      storage = var.uploads_storage_size
    }
    access_modes = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs.metadata[0].name
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${var.efs_id}:/uploads"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "output" {
  metadata {
    name = "voice-app-output-pv"
  }
  spec {
    capacity = {
      storage = var.output_storage_size
    }
    access_modes = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs.metadata[0].name
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${var.efs_id}:/output"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "uploads" {
  metadata {
    name      = "voice-app-uploads"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs.metadata[0].name
    volume_name = kubernetes_persistent_volume.uploads.metadata[0].name
    resources {
      requests = {
        storage = var.uploads_storage_size
      }
    }
  }

  depends_on = [var.voice_app_release_id]
}

resource "kubernetes_persistent_volume_claim" "output" {
  metadata {
    name      = "voice-app-output"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs.metadata[0].name
    volume_name = kubernetes_persistent_volume.output.metadata[0].name
    resources {
      requests = {
        storage = var.output_storage_size
      }
    }
  }

  depends_on = [var.voice_app_release_id]
}