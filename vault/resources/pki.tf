resource "vault_mount" "homelab_root_ca" {
  path        = "homelab-root-ca"
  type        = "pki"
  description = "Homelab Root CA"

  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 157788000
}

resource "vault_mount" "homelab_int_ca" {
  path        = "homelab-int-ca"
  type        = "pki"
  description = "Homelab Intermediate CA"

  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 31557600
}

resource "vault_pki_secret_backend_role" "cert_manager_kubernetes_dashboard" {
  backend                     = vault_mount.homelab_int_ca.path
  name                        = "cert-manager-kubernetes-dashboard"
  ttl                         = 3600
  key_type                    = "ec"
  key_bits                    = 256
  allowed_domains             = ["dashboard.kubernetes.homelab"]
  allow_bare_domains          = true
  allow_ip_sans               = false
  allow_wildcard_certificates = false
  allow_localhost             = false
  require_cn                  = false
  key_usage                   = ["DigitalSignature"]
  ext_key_usage               = ["ServerAuth"]
}
