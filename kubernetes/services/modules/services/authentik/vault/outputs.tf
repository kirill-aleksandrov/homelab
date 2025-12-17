output "vault_secret_key_mount_path" {
  value = vault_kv_secret_v2.authentik.mount
}

output "vault_secret_key_secret_name" {
  value = vault_kv_secret_v2.authentik.name
}
