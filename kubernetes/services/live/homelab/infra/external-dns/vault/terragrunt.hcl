include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../../modules/services/external-dns/vault"
}

dependency "namespace" {
  config_path = "../namespace"

  mock_outputs = {
    namespace = "external-dns"
  }
}

dependency "vault_connection" {
  config_path = "../../vault-secrets-operator/connection"

  mock_outputs = {
    global_auth_namespace = "vault-secrets-operator"
    global_auth_name      = "kubernetes-global-auth"
  }
}

inputs = {
  namespace                   = dependency.namespace.outputs.namespace
  vault_tsig_read_policy_name = include.root.locals.vault_tsig_read_policy_name
  vault_tsig_mount_path       = include.root.locals.vault_tsig_mount_path
  vault_tsig_secret_name      = include.root.locals.vault_tsig_secret_name
  global_auth_namespace       = dependency.vault_connection.outputs.global_auth_namespace
  global_auth_name            = dependency.vault_connection.outputs.global_auth_name
}
