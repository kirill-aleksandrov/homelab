locals {
  secret_path = "homelab-bind9"
  secret_name = "rfc2136-tsig"
}

resource "vault_mount" "bind9_mount" {
  path = local.secret_path
  type = "kv-v2"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_v2" "bind9_secret" {
  mount = vault_mount.bind9_mount.path
  name  = local.secret_name

  # Placeholder values
  # Secrets need to be provided after creation
  data_json = jsonencode({
    secret     = "secret"
    secret-alg = "secret-alg"
    keyname    = "keyname"
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}

resource "vault_policy" "bind9_read_policy" {
  name   = "${vault_kv_secret_v2.bind9_secret.mount}-${vault_kv_secret_v2.bind9_secret.name}-read"
  policy = <<-EOT
    path "${vault_kv_secret_v2.bind9_secret.mount}/data/${vault_kv_secret_v2.bind9_secret.name}" {
      capabilities = ["read", "list"]
    }
  EOT
}
