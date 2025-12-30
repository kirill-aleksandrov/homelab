include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../..//modules/services/prometheus-stack/app"
}

dependencies {
  paths = [
    "../../../infra/external-dns/operator",
    "../../../infra/cert-manager/vault",
    "../../../infra/ingress-nginx",
    "../../../infra/authentik/app",
  ]
}

dependency "vault_connection" {
  config_path = "../../../infra/vault-secrets-operator/connection"

  mock_outputs = {
    global_auth_namespace   = "vault-secrets-operator"
    global_auth_name        = "kubernetes-global-auth"
    vault_auth_backend_path = "vault-secrets-operator"
  }
}

dependency "vault" {
  config_path = "../vault"

  mock_outputs = {
    vault_prometheus_mount_path   = "prometheus"
    vault_alertmanager_mount_path = "alertmanager"
    vault_grafana_mount_path      = "grafana"
  }
}

dependency "prometheus_oauth2_provider" {
  config_path = "../prometheus_oauth2_provider"

  mock_outputs = {
    oauth2_application_slug              = "prometheus"
    vault_client_secret_secret_name      = "oauth2-provider"
    vault_client_secret_read_policy_name = "prometheus-oauth2-provider-read"
  }
}

dependency "prometheus_oauth2_proxy_cookie_secret" {
  config_path = "../prometheus_oauth2_proxy_cookie_secret"

  mock_outputs = {
    vault_cookie_secret_secret_name      = "oauth2-proxy"
    vault_cookie_secret_read_policy_name = "prometheus-oauth2-proxy-read"
  }
}

dependency "alertmanager_oauth2_provider" {
  config_path = "../alertmanager_oauth2_provider"

  mock_outputs = {
    oauth2_application_slug              = "alertmanager"
    vault_client_secret_secret_name      = "oauth2-provider"
    vault_client_secret_read_policy_name = "alertmanager-oauth2-provider-read"
  }
}

dependency "alertmanager_oauth2_proxy_cookie_secret" {
  config_path = "../alertmanager_oauth2_proxy_cookie_secret"

  mock_outputs = {
    vault_cookie_secret_secret_name      = "oauth2-proxy"
    vault_cookie_secret_read_policy_name = "alertmanager-oauth2-proxy-read"
  }
}

dependency "grafana_oauth2_provider" {
  config_path = "../grafana_oauth2_provider"

  mock_outputs = {
    oauth2_application_slug              = "grafana"
    vault_client_secret_secret_name      = "oauth2-provider"
    vault_client_secret_read_policy_name = "grafana-oauth2-provider-read"
  }
}

inputs = {
  authentik_url             = include.root.locals.authentik_url
  authentik_token           = include.root.locals.authentik_token
  root_ca                   = include.root.locals.root_ca
  vault_address             = include.root.locals.vault_address
  vault_int_ca_backend_path = include.root.locals.vault_int_ca_backend_path

  vault_global_auth_namespace = dependency.vault_connection.outputs.global_auth_namespace
  vault_global_auth_name      = dependency.vault_connection.outputs.global_auth_name
  vault_auth_backend_path     = dependency.vault_connection.outputs.vault_auth_backend_path

  vault_prometheus_mount_path                     = dependency.vault.outputs.vault_prometheus_mount_path
  oauth2_prometheus_application_slug              = dependency.prometheus_oauth2_provider.outputs.oauth2_application_slug
  vault_prometheus_client_secret_secret_name      = dependency.prometheus_oauth2_provider.outputs.vault_client_secret_secret_name
  vault_prometheus_client_secret_read_policy_name = dependency.prometheus_oauth2_provider.outputs.vault_client_secret_read_policy_name
  vault_prometheus_cookie_secret_secret_name      = dependency.prometheus_oauth2_proxy_cookie_secret.outputs.vault_cookie_secret_secret_name
  vault_prometheus_cookie_secret_read_policy_name = dependency.prometheus_oauth2_proxy_cookie_secret.outputs.vault_cookie_secret_read_policy_name

  vault_alertmanager_mount_path                     = dependency.vault.outputs.vault_alertmanager_mount_path
  oauth2_alertmanager_application_slug              = dependency.alertmanager_oauth2_provider.outputs.oauth2_application_slug
  vault_alertmanager_client_secret_secret_name      = dependency.alertmanager_oauth2_provider.outputs.vault_client_secret_secret_name
  vault_alertmanager_client_secret_read_policy_name = dependency.alertmanager_oauth2_provider.outputs.vault_client_secret_read_policy_name
  vault_alertmanager_cookie_secret_secret_name      = dependency.alertmanager_oauth2_proxy_cookie_secret.outputs.vault_cookie_secret_secret_name
  vault_alertmanager_cookie_secret_read_policy_name = dependency.alertmanager_oauth2_proxy_cookie_secret.outputs.vault_cookie_secret_read_policy_name

  vault_grafana_mount_path                     = dependency.vault.outputs.vault_grafana_mount_path
  oauth2_grafana_application_slug              = dependency.grafana_oauth2_provider.outputs.oauth2_application_slug
  vault_grafana_client_secret_secret_name      = dependency.grafana_oauth2_provider.outputs.vault_client_secret_secret_name
  vault_grafana_client_secret_read_policy_name = dependency.grafana_oauth2_provider.outputs.vault_client_secret_read_policy_name
}
