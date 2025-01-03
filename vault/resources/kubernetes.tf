resource "vault_auth_backend" "kubernetes_cert_manager" {
  type = "kubernetes"
  path = "kubernetes-cert-manager"
}
