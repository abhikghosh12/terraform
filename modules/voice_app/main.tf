resource "helm_release" "voice_app" {
  name       = var.release_name
  chart      = var.chart_path
  version    = var.chart_version
  namespace  = var.namespace

  values = [
    templatefile(var.values_template_path, {
      webapp_image_tag     = var.webapp_image_tag
      webapp_replica_count = var.webapp_replica_count
      worker_image_tag     = var.worker_image_tag
      worker_replica_count = var.worker_replica_count
      ingress_enabled      = var.ingress_enabled
      ingress_host         = var.ingress_host
    })
  ]

  timeout = 900  # Increase timeout to 15 minutes

  depends_on = [var.cluster_name]
}