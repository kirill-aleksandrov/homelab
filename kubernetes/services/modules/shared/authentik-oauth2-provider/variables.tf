variable "authentik_url" {
  type = string
}

variable "authentik_token" {
  type      = string
  sensitive = true
}

variable "name" {
  type = string
}

variable "allowed_redirect_uri" {
  type = string
}

variable "vault_mount_path" {
  type = string
}
