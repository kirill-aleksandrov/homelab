resource "vault_kv_secret_v2" "cookie_secret" {
  mount = var.vault_mount_path
  name  = "oauth2-proxy"

  # Placeholder values
  # Secret will be created by terragrunt after hook
  data_json = jsonencode({
    "cookie-secret" = "cookie-secret"
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}

resource "vault_policy" "cookie_secret_read" {
  name   = "${var.vault_mount_path}-${vault_kv_secret_v2.cookie_secret.name}-read"
  policy = <<-EOT
    path "${var.vault_mount_path}/data/${vault_kv_secret_v2.cookie_secret.name}" {
      capabilities = ["read"]
    }
  EOT
}
