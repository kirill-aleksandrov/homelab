resource "kubernetes_namespace" "chart_namespace" {
  metadata {
    name = local.chart_name
  }
}

resource "kubernetes_namespace" "node_exporter_namespace" {
  metadata {
    name = local.node_exporter_namespace
    labels = {
      "pod-security.kubernetes.io/enforce"         = "privileged"
      "pod-security.kubernetes.io/enforce-version" = "v1.33"
      "pod-security.kubernetes.io/warn"            = "restricted"
      "pod-security.kubernetes.io/audit"           = "restricted"
    }
  }
}
