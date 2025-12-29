output "vault_prometheus_mount_path" {
  value = vault_mount.prometheus.path
}

output "vault_alertmanager_mount_path" {
  value = vault_mount.alertmanager.path
}

output "vault_grafana_mount_path" {
  value = vault_mount.grafana.path
}
