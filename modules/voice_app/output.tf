output "helm_status" {
  value = helm_release.voice_app.status
}

output "helm_release_id" {
  value       = helm_release.voice_app.id
  description = "The ID of the Helm release for the voice app"
}

output "release_name" {
  description = "The name of the Helm release"
  value       = helm_release.voice_app.name
}

output "release_status" {
  description = "The status of the Helm release"
  value       = helm_release.voice_app.status
}


output "namespace" {
  description = "The namespace where the application is deployed"
  value       = var.namespace
}