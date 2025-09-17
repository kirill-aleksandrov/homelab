resource "vault_kubernetes_auth_backend_role" "external-dns" {
  backend                          = vault_auth_backend.kubernetes_vault_secrets_operator.path
  role_name                        = "external-dns"
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = ["*"]
  audience                         = "external-dns"
  token_policies                   = [vault_policy.bind9_read.name]
}
