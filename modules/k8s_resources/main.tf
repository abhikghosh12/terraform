# modules/k8s_resources/main.tf

resource "kubernetes_namespace" "voice_app" {
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

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

locals {
  pv_configs = [
    { name = "voice-app-uploads", size = var.uploads_storage_size },
    { name = "voice-app-output", size = var.output_storage_size },
    { name = "redis-master", size = "2Gi" },
    { name = "redis-replicas", size = "2Gi" },
  ]
}

resource "kubernetes_persistent_volume" "voice_app_pvs" {
  for_each = { for idx, config in local.pv_configs : config.name => config }

  metadata {
    name = "pv-${each.key}"
  }
  spec {
    capacity = {
      storage = each.value.size
    }
    access_modes = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs.metadata[0].name
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${var.efs_id}:/${each.key}"
      }
    }
  }

  # lifecycle {
  #   # Temporarily comment out prevent_destroy
  #   # prevent_destroy = true
  #   ignore_changes = [
  #     metadata[0].annotations,
  #     metadata[0].labels,
  #   ]
  # }
}

