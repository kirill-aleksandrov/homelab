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

module "prometheus_issuer" {
  source = "../../shared/cert-manager-vault-issuer"

  name                      = "prometheus"
  namespace                 = kubernetes_namespace.chart_namespace.metadata[0].name
  domain                    = "prometheus.homelab"
  root_ca                   = var.root_ca
  vault_address             = var.vault_address
  vault_int_ca_backend_path = var.vault_int_ca_backend_path
}

module "grafana_issuer" {
  source = "../../shared/cert-manager-vault-issuer"

  name                      = "grafana"
  namespace                 = kubernetes_namespace.chart_namespace.metadata[0].name
  domain                    = "grafana.homelab"
  root_ca                   = var.root_ca
  vault_address             = var.vault_address
  vault_int_ca_backend_path = var.vault_int_ca_backend_path
}

module "alertmanager_issuer" {
  source = "../../shared/cert-manager-vault-issuer"

  name                      = "alertmanager"
  namespace                 = kubernetes_namespace.chart_namespace.metadata[0].name
  domain                    = "alertmanager.homelab"
  root_ca                   = var.root_ca
  vault_address             = var.vault_address
  vault_int_ca_backend_path = var.vault_int_ca_backend_path
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
          annotations = {
            "cert-manager.io/issuer"                = module.prometheus_issuer.issuer_name
            "cert-manager.io/private-key-algorithm" = "ECDSA"
            "cert-manager.io/private-key-size"      = "384"
          }
          tls = [
            {
              hosts      = ["prometheus.homelab"]
              secretName = "prometheus-cert"
            }
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
      alertmanager = {
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hosts = [
            "alertmanager.homelab"
          ]
          annotations = {
            "cert-manager.io/issuer"                = module.alertmanager_issuer.issuer_name
            "cert-manager.io/private-key-algorithm" = "ECDSA"
            "cert-manager.io/private-key-size"      = "384"
          }
          tls = [
            {
              hosts      = ["alertmanager.homelab"]
              secretName = "alertmanager-cert"
            }
          ]
        }
      }
    })
  ]
}
