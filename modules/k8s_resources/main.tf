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
}

resource "kubernetes_persistent_volume_claim" "voice_app_pvcs" {
  for_each = { for idx, config in local.pv_configs : config.name => config }

  metadata {
    name      = each.key
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs.metadata[0].name
    volume_name = kubernetes_persistent_volume.voice_app_pvs[each.key].metadata[0].name
    resources {
      requests = {
        storage = each.value.size
      }
    }
  }
}

# modules/k8s_resources/main.tf

# ... existing resources ...

resource "kubernetes_persistent_volume" "redis_master" {
  metadata {
    name = "pv-redis-data-voice-app-redis-master-0"
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "efs-sc"
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${var.efs_id}:/redis-master"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "redis_replicas" {
  metadata {
    name = "pv-redis-data-voice-app-redis-replicas-0"
  }
  spec {
    capacity = {
      storage = "8Gi"
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "efs-sc"
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle = "${var.efs_id}:/redis-replicas"
      }
    }
  }
}