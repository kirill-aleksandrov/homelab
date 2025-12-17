include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/services/authentik/app"
}

dependencies {
  paths = [
    "../../external-dns/operator",
    "../../topo-lvm",
    "../../cloudnative-pg",
    "../../cert-manager/vault",
    "../../ingress-nginx",
  ]
}

dependency "namespace" {
  config_path = "../namespace"

  mock_outputs = {
    namespace = "authentik"
  }
}

dependency "vault" {
  config_path = "../vault"

  mock_outputs = {
    vault_secret_key_mount_path  = "authentik"
    vault_secret_key_secret_name = "secret-key"
  }
}


dependency "vault_connection" {
  config_path = "../../vault-secrets-operator/connection"

  mock_outputs = {
    global_auth_namespace   = "vault-secrets-operator"
    global_auth_name        = "kubernetes-global-auth"
    vault_auth_backend_path = "vault-secrets-operator"
  }
}

inputs = {
  namespace                    = dependency.namespace.outputs.namespace
  root_ca                      = include.root.locals.root_ca
  vault_int_ca_backend_path    = include.root.locals.vault_int_ca_backend_path
  vault_secret_key_mount_path  = dependency.vault.outputs.vault_secret_key_mount_path
  vault_secret_key_secret_name = dependency.vault.outputs.vault_secret_key_secret_name
  global_auth_namespace        = dependency.vault_connection.outputs.global_auth_namespace
  global_auth_name             = dependency.vault_connection.outputs.global_auth_name
  vault_auth_backend_path      = dependency.vault_connection.outputs.vault_auth_backend_path
}
