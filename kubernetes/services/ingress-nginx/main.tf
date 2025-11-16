locals {
  chart_name = "ingress-nginx"
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = local.chart_name
  }
}

resource "helm_release" "external_dns" {
  name       = local.chart_name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = local.chart_name
  version    = "4.14.0"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
}
