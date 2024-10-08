output "storage_class_name" {
  value = kubernetes_storage_class.efs.metadata[0].name
}


