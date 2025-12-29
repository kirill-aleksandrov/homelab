output "oauth2_application_slug" {
  value = authentik_application.application.slug
}

output "vault_client_secret_secret_name" {
  value = vault_kv_secret_v2.client_secret.name
}

output "vault_client_secret_read_policy_name" {
  value = vault_policy.client_secret_read.name
}

output "authentik_provider_id" {
  value = authentik_provider_oauth2.provider.id
}
