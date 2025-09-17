resource "vault_auth_backend" "kubernetes_cert_manager" {
  type = "kubernetes"
  path = "kubernetes-cert-manager"
}

resource "vault_auth_backend" "kubernetes_vault_secrets_operator" {
  type = "kubernetes"
  path = "kubernetes-vault-secrets-operator"
}
