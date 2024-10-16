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

resource "kubernetes_daemonset" "check_update_efs_utils" {
  metadata {
    name      = "check-update-efs-utils"
    namespace = "kube-system"
  }

  spec {
    selector {
      match_labels = {
        name = "check-update-efs-utils"
      }
    }

    template {
      metadata {
        labels = {
          name = "check-update-efs-utils"
        }
      }

      spec {
        container {
          name    = "check-update-efs-utils"
          image   = "amazon/aws-cli"
          command = ["/bin/bash", "-c"]
          args    = [
            <<-EOT
            yum install -y amazon-efs-utils
            systemctl enable amazon-efs-mount-watchdog
            systemctl start amazon-efs-mount-watchdog
            cp /etc/amazon/efs/efs-utils.conf /etc/amazon/efs/efs-utils.conf.bak
            echo "fips_mode_enabled = false" >> /etc/amazon/efs/efs-utils.conf
            echo "retry_nfs_mount_command = true" >> /etc/amazon/efs/efs-utils.conf
            EOT
          ]

          security_context {
            privileged = true
          }
        }

        host_network = true
        host_pid     = true
      }
    }
  }
}

# Job to test EFS mount
resource "kubernetes_job" "test_efs_mount" {
  metadata {
    name = "test-efs-mount"
  }

  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "test-mount"
          image   = "amazon/aws-cli"
          command = ["/bin/bash", "-c"]
          args    = [
            <<-EOT
            mkdir -p /mnt/efs
            mount -t efs -o tls,accesspoint=${var.efs_access_point_id} ${var.efs_id}:/ /mnt/efs
            if [ $? -eq 0 ]; then
              echo "Mount successful"
              ls -la /mnt/efs
              umount /mnt/efs
            else
              echo "Mount failed"
            fi
            EOT
          ]

          security_context {
            privileged = true
          }
        }

        restart_policy = "Never"
      }
    }
  }
}

# Update PersistentVolume configuration
resource "kubernetes_persistent_volume" "voice_app_pvs" {
  for_each = { for idx, config in local.pv_configs : config.name => config }

  metadata {
    name = "pv-${each.key}"
  }
  spec {
    capacity = {
      storage = each.value.size
    }
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.efs.metadata[0].name
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      csi {
        driver        = "efs.csi.aws.com"
        volume_handle = "${var.efs_id}::${var.efs_access_point_id}"
      }
    }
    mount_options = ["tls", "iam"]
  }
}