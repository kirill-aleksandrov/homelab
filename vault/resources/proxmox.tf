resource "vault_pki_secret_backend_role" "proxmox_role" {
  backend          = vault_mount.homelab-int-ca-mount.path
  name             = "proxmox"
  ttl              = 3600
  key_type         = "ec"
  key_bits         = 256
  allowed_domains  = ["proxmox.homelab"]
  allow_subdomains = true
  key_usage        = ["DigitalSignature"]
  ext_key_usage    = ["ServerAuth"]
}
