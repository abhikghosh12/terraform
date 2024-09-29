# modules/voice_app/main.tf
resource "local_file" "helm_values" {
  content = templatefile("${path.root}/templates/voice_app_values.yaml.tpl", {
    webapp_image_tag     = var.webapp_image_tag
    webapp_replica_count = var.webapp_replica_count
    worker_image_tag     = var.worker_image_tag
    worker_replica_count = var.worker_replica_count
    ingress_enabled      = var.ingress_enabled
    ingress_host         = var.ingress_host
  })
  filename = "${path.module}/generated_values.yaml"
}

resource "helm_release" "voice_app" {
  name       = var.release_name
  chart      = var.chart_path
  version    = var.chart_version
  namespace  = var.namespace

  values = [
    local_file.helm_values.content
  ]

  depends_on = [local_file.helm_values]
}
