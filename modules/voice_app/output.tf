output "ingress_hostname" {
  description = "Hostname of the Voice App ingress"
  value       = try(data.kubernetes_ingress_v1.voice_app.status[0].load_balancer[0].ingress[0].hostname, "")
}

output "helm_status" {
  value = helm_release.voice_app.status
}
