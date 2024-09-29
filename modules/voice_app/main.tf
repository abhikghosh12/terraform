# modules/voice_app/main.tf

resource "helm_release" "voice_app" {
  name       = var.release_name
  chart      = "${path.root}/voice/helm/voice"  # Path to your local chart
  version    = var.chart_version
  namespace  = var.namespace

  # If you have values file in your chart directory
  values = [
    file("${path.root}/voice/helm/voice/values.yaml")
  ]

  # You can add additional value overrides here
  set {
    name  = "replicaCount"
    value = var.replica_count
  }

  # Add more 'set' blocks for other values you want to override

  depends_on = [
    # Add any dependencies here, e.g., kubernetes_namespace.voice_namespace
  ]
}

