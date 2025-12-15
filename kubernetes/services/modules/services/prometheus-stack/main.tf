locals {
  chart_name              = "kube-prometheus-stack"
  node_exporter_namespace = "prometheus-node-exporter"
}

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

resource "helm_release" "prometheus" {
  name       = local.chart_name
  repository = "oci://ghcr.io/prometheus-community/charts"
  chart      = local.chart_name
  version    = "79.7.1"
  namespace  = kubernetes_namespace.chart_namespace.metadata[0].name

  values = [
    yamlencode({
      prometheus-node-exporter = {
        namespaceOverride = kubernetes_namespace.node_exporter_namespace.metadata[0].name
      }
      prometheus = {
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hosts = [
            "prometheus.homelab"
          ]
        }
      }
      grafana = {
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hosts = [
            "grafana.homelab"
          ]
        }
      }
      alertmanager = {
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hosts = [
            "alertmanager.homelab"
          ]
        }
      }
    })
  ]
}
