output "vault_cookie_secret_secret_name" {
  value = vault_kv_secret_v2.cookie_secret.name
}

output "vault_cookie_secret_read_policy_name" {
  value = vault_policy.cookie_secret_read.name
}
