include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/services/authentik/vault"

  after_hook "configure_vault_auth" {
    commands = ["apply"]
    execute  = ["./generate-secret-key.sh"]
  }
}
