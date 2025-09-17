locals {
  chart_name = "ingress-nginx"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.chart_name
  }
}

resource "helm_release" "release" {
  name       = local.chart_name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = local.chart_name
  version    = "4.12.3"
  namespace  = kubernetes_namespace.namespace.metadata[0].name
}
