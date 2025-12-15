output "global_auth_namespace" {
  value = kubernetes_manifest.global_auth.manifest.metadata.namespace
}

output "global_auth_name" {
  value = kubernetes_manifest.global_auth.manifest.metadata.name
}
