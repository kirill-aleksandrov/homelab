resource "vault_mount" "bind9" {
  path        = "bind9"
  type        = "kv-v2"
  description = "Bind9 static secrets"
}

resource "vault_policy" "bind9_read" {
  name   = "bind9-read"
  policy = <<EOT
path "${vault_mount.bind9.path}/data/*" {
  capabilities = ["read"]
}
EOT
}
