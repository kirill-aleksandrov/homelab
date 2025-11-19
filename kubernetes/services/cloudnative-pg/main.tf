locals {
  chart_name = "cloudnative-pg"
}

resource "kubernetes_namespace" "cloudnative_pg" {
  metadata {
    name = local.chart_name
  }
}

resource "helm_release" "cloudnative_pg" {
  name       = local.chart_name
  repository = "https://cloudnative-pg.github.io/charts"
  chart      = local.chart_name
  version    = "0.26.1"
  namespace  = kubernetes_namespace.cloudnative_pg.metadata[0].name
}
