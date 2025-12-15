output "tsig_secret_name" {
  value = kubernetes_manifest.tsig_secret.manifest.metadata.name
}
