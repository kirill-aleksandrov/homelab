include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../../modules/shared/oauth2-proxy-cookie-secret"

  after_hook "generate_cookie_secret" {
    commands = ["apply"]
    execute  = ["./generate-cookie-secret.sh"]
  }
}

dependency "vault" {
  config_path = "../vault"

  mock_outputs = {
    vault_prometheus_mount_path = "prometheus"
    vault_alertmanager_mount_path = "alertmanager"
    vault_grafana_mount_path = "grafana"
  }
}

inputs = {
  vault_mount_path = dependency.vault.outputs.vault_prometheus_mount_path
}
