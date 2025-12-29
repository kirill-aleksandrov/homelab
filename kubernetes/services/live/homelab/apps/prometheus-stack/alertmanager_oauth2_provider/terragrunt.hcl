include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../../modules/shared/authentik-oauth2-provider"

  after_hook "generate_client_secret" {
    commands = ["apply"]
    execute  = ["./generate-client-secret.sh"]
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

inputs = {
  authentik_url        = include.root.locals.authentik_url
  authentik_token      = include.root.locals.authentik_token
  name                 = "alertmanager"
  allowed_redirect_uri = "https://alertmanager.homelab/oauth2/callback"
  vault_mount_path     = dependency.vault.outputs.vault_alertmanager_mount_path
}
