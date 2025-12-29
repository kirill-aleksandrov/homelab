resource "helm_release" "prometheus_stack" {
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
          enabled = false
        }
      }
      alertmanager = {
        ingress = {
          enabled = false
        }
      }
      grafana = {
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hosts = [
            "grafana.homelab"
          ]
          annotations = {
            "cert-manager.io/issuer"                = module.grafana_issuer.issuer_name
            "cert-manager.io/private-key-algorithm" = "ECDSA"
            "cert-manager.io/private-key-size"      = "384"
          }
          tls = [
            {
              hosts      = ["grafana.homelab"]
              secretName = "grafana-cert"
            }
          ]
        }
      }
    })
  ]
}
