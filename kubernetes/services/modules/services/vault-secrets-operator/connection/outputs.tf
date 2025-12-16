output "global_auth_namespace" {
  value = kubernetes_manifest.global_auth.manifest.metadata.namespace
}

output "global_auth_name" {
  value = kubernetes_manifest.global_auth.manifest.metadata.name
}

# outputs used by after_hook
output "vault_auth_backend_path" {
  value = vault_auth_backend.vault_auth_backend.path
}

output "token_reviewer_service_account_namespace" {
  value = kubernetes_service_account.token_reviewer_service_account.metadata[0].namespace
}

output "token_reviewer_service_account_name" {
  value = kubernetes_service_account.token_reviewer_service_account.metadata[0].name
}
