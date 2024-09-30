resource "helm_release" "namespace" {
  name       = "${var.namespace}-namespace"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "common"
  version    = "2.4.0"  # Use the latest 1.x version
  namespace  = var.namespace
  create_namespace = true

  set {
    name  = "namespaceCreate"
    value = "true"
  }
}

resource "helm_release" "voice_app" {
  name       = var.release_name
  chart      = var.chart_path
  namespace  = var.namespace

  set {
    name  = "webapp.image.tag"
    value = var.webapp_image_tag
  }

  set {
    name  = "worker.image.tag"
    value = var.worker_image_tag
  }

  set {
    name  = "webapp.replicaCount"
    value = var.webapp_replica_count
  }

  set {
    name  = "worker.replicaCount"
    value = var.worker_replica_count
  }

  set {
    name  = "ingress.enabled"
    value = var.ingress_enabled
  }

  set {
    name  = "ingress.host"
    value = var.ingress_host
  }

  timeout = 900  # 15 minutes

  depends_on = [helm_release.namespace]
}

data "kubernetes_ingress_v1" "voice_app" {
  metadata {
    name      = "${var.release_name}-ingress"
    namespace = var.namespace
  }

  depends_on = [helm_release.voice_app]
}

output "ingress_hostname" {
  description = "Hostname of the Voice App ingress"
  value       = data.kubernetes_ingress_v1.voice_app.status.0.load_balancer.0.ingress.0.hostname
}