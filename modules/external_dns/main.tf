resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "6.20.4"  # Specify a version

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.zoneType"
    value = "public"
  }

  set {
    name  = "domainFilters[0]"
    value = var.domain_name
  }

  set {
    name  = "txtOwnerId"
    value = var.cluster_name
  }

  timeout = 900  # Increase timeout to 15 minutes

  depends_on = [var.cluster_name]  # Ensure EKS cluster is ready before installing
}
