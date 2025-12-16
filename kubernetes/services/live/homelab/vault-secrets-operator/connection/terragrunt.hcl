include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/services/vault-secrets-operator/connection"

  after_hook "configure_vault_auth" {
    commands     = ["apply"]
    execute      = ["./configure-vault-auth.sh"]
  }
}

dependency "operator" {
  config_path = "../operator"

  mock_outputs = {
    namespace = "vault-secrets-operator"
  }
}

inputs = {
  namespace = dependency.operator.outputs.namespace
  root_ca   = include.root.locals.root_ca
}
