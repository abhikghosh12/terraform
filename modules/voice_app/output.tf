output "helm_status" {
  value = helm_release.voice_app.status
}

output "helm_release_id" {
  value       = helm_release.voice_app.id
  description = "The ID of the Helm release for the voice app"
}

output "ingress_host" {
  value       = try(data.kubernetes_ingress_v1.voice_app.status[0].load_balancer[0].ingress[0].hostname, "")
  description = "The hostname of the ingress for the voice app"
}