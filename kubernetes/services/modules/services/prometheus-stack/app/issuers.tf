module "prometheus_issuer" {
  source = "../../../shared/cert-manager-vault-issuer"

  name                      = "prometheus"
  namespace                 = kubernetes_namespace.chart_namespace.metadata[0].name
  domain                    = "prometheus.homelab"
  root_ca                   = var.root_ca
  vault_address             = var.vault_address
  vault_int_ca_backend_path = var.vault_int_ca_backend_path
}

module "grafana_issuer" {
  source = "../../../shared/cert-manager-vault-issuer"

  name                      = "grafana"
  namespace                 = kubernetes_namespace.chart_namespace.metadata[0].name
  domain                    = "grafana.homelab"
  root_ca                   = var.root_ca
  vault_address             = var.vault_address
  vault_int_ca_backend_path = var.vault_int_ca_backend_path
}

module "alertmanager_issuer" {
  source = "../../../shared/cert-manager-vault-issuer"

  name                      = "alertmanager"
  namespace                 = kubernetes_namespace.chart_namespace.metadata[0].name
  domain                    = "alertmanager.homelab"
  root_ca                   = var.root_ca
  vault_address             = var.vault_address
  vault_int_ca_backend_path = var.vault_int_ca_backend_path
}
