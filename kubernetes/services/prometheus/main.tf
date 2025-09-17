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
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "restricted"
      "pod-security.kubernetes.io/audit"   = "restricted"
    }
  }
}

resource "helm_release" "release" {
  name       = local.chart_name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = local.chart_name
  version    = "73.2.0"
  namespace  = kubernetes_namespace.chart_namespace.metadata[0].name

  values = [yamlencode({
    prometheus-node-exporter = {
      namespaceOverride = kubernetes_namespace.node_exporter_namespace.metadata[0].name
    }
    alertmanager = {
      ingress = {
        enabled          = true
        hosts            = ["alertmanager.homelab"]
        ingressClassName = "nginx"
      }
    }
    grafana = {
      ingress = {
        enabled          = true
        hosts            = ["grafana.homelab"]
        ingressClassName = "nginx"
      }
    }
    prometheus = {
      ingress = {
        enabled          = true
        hosts            = ["prometheus.homelab"]
        ingressClassName = "nginx"
      }
    }
  })]
}
