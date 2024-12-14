resource "vault_mount" "homelab-root-ca-mount" {
  path        = "homelab-root-ca"
  type        = "pki"
  description = "Homelab Root CA"

  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 157788000
}

resource "vault_mount" "homelab-int-ca-mount" {
  path        = "homelab-int-ca"
  type        = "pki"
  description = "Homelab Intermediate CA"

  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 31557600
}
