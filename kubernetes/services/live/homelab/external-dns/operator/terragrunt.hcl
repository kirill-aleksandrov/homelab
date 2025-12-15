include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../../modules/services/external-dns/operator"
}

dependency "namespace" {
  config_path = "../namespace"

  mock_outputs = {
    namespace = "external-dns"
  }
}

dependency "vault" {
  config_path = "../../external-dns/vault"

  mock_outputs = {
    tsig_secret_name = "rfc2136-tsig"
  }
}

inputs = {
  namespace        = dependency.namespace.outputs.namespace
  tsig_secret_name = dependency.vault.outputs.tsig_secret_name
}
