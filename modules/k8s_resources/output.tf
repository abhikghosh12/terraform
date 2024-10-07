output "storage_class_name" {
  value = kubernetes_storage_class.efs.metadata[0].name
}

output "pvc_names" {
  value = [for pvc in kubernetes_persistent_volume_claim.voice_app_pvcs : pvc.metadata[0].name]
}
