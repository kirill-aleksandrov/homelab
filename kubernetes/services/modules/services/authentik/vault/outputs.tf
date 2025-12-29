output "vault_secret_key_mount_path" {
  value = vault_kv_secret_v2.secret_key.mount
}

output "vault_secret_key_secret_name" {
  value = vault_kv_secret_v2.secret_key.name
}

output "vault_oauth2_mount_path" {
  value = vault_mount.oauth2.path
}
