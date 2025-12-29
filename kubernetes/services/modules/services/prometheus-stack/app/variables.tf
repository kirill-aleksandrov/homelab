variable "authentik_url" {
  type = string
}

variable "authentik_token" {
  type      = string
  sensitive = true
}

variable "root_ca" {
  type = string
}

variable "vault_address" {
  type = string
}

variable "vault_int_ca_backend_path" {
  type = string
}

variable "vault_global_auth_namespace" {
  type = string
}

variable "vault_global_auth_name" {
  type = string
}

variable "vault_auth_backend_path" {
  type = string
}

# Prometheus oauth2
variable "vault_prometheus_mount_path" {
  type = string
}

variable "oauth2_prometheus_application_slug" {
  type = string
}

variable "vault_prometheus_client_secret_secret_name" {
  type = string
}

variable "vault_prometheus_client_secret_read_policy_name" {
  type = string
}

variable "vault_prometheus_cookie_secret_secret_name" {
  type = string
}

variable "vault_prometheus_cookie_secret_read_policy_name" {
  type = string
}

# Alertmanager oauth2
variable "vault_alertmanager_mount_path" {
  type = string
}

# Grafana oauth2
variable "vault_grafana_mount_path" {
  type = string
}
