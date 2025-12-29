module "issuer" {
  source = "../../../shared/cert-manager-vault-issuer"

  name                      = "authentik"
  namespace                 = var.namespace
  domain                    = "authentik.homelab"
  root_ca                   = var.root_ca
  vault_address             = var.vault_address
  vault_int_ca_backend_path = var.vault_int_ca_backend_path
}
