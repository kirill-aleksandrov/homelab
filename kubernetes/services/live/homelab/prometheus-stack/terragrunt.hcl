include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../..//modules/services/prometheus-stack"
}

dependencies {
  paths = [
    "../external-dns/operator",
    "../cert-manager/vault",
    "../ingress-nginx",
  ]
}

inputs = {
  root_ca                   = include.root.locals.root_ca
  vault_address             = include.root.locals.vault_address
  vault_int_ca_backend_path = include.root.locals.vault_int_ca_backend_path
}
