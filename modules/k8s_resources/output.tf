# modules/k8s_resources/outputs.tf

output "storage_class_name" {
  value = kubernetes_storage_class.efs.metadata[0].name
}

output "pv_names" {
  description = "Map of created Persistent Volume names"
  value = {for k, v in kubernetes_persistent_volume.voice_app_pvs : k => v.metadata[0].name}
}

output "namespace_id" {
  value = kubernetes_namespace.voice_app.id
}