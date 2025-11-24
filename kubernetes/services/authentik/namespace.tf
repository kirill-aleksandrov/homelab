resource "kubernetes_namespace" "authentik" {
  metadata {
    name = local.chart_name
  }
}
