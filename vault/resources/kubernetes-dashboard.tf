resource "vault_kubernetes_auth_backend_role" "kubernetes_dashboard" {
  backend                          = vault_auth_backend.kubernetes_cert_manager.path
  role_name                        = "kubernetes-dashboard"
  bound_service_account_names      = ["vault-issuer"]
  bound_service_account_namespaces = ["kubernetes-dashboard"]
  audience                         = "vault://kubernetes-dashboard/vault-issuer"
  token_policies                   = [vault_policy.cert_manager_kubernetes_dashboard_policy.name]
}

resource "vault_policy" "cert_manager_kubernetes_dashboard_policy" {
  name   = "cert-create-kubernetes-dashboard"
  policy = <<EOT
path "${vault_mount.homelab_int_ca.path}/sign/${vault_pki_secret_backend_role.cert_manager_kubernetes_dashboard.name}" {
  capabilities = ["update"]
}
EOT
}
