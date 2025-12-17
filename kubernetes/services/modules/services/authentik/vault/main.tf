resource "vault_mount" "authentik" {
  path = "authentik"
  type = "kv-v2"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_v2" "authentik" {
  mount = vault_mount.authentik.path
  name  = "secret-key"

  # Placeholder values
  # Secrets need to be provided after creation
  data_json = jsonencode({
    "secret-key" = "secret"
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}
