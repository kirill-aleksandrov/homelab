resource "vault_mount" "authentik" {
  path = "authentik"
  type = "kv-v2"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_v2" "secret_key" {
  mount = vault_mount.authentik.path
  name  = "secret-key"

  # Placeholder values
  # Secret will be created by terragrunt after hook
  data_json = jsonencode({
    "secret-key" = "secret"
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}

resource "vault_kv_secret_v2" "token" {
  mount = vault_mount.authentik.path
  name  = "token"

  # Placeholder values
  # Token need to be manually set
  data_json = jsonencode({
    "token" = "token"
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}

# Mount to store oauth2 secrets. It's used by oauth2 clients
resource "vault_mount" "oauth2" {
  path = "oauth2"
  type = "kv-v2"
  options = {
    version = "2"
  }
}
