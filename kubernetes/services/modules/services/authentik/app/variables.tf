variable "namespace" {
  type = string
}

variable "root_ca" {
  type = string
}

variable "vault_secret_key_mount_path" {
  type = string
}

variable "vault_secret_key_secret_name" {
  type = string
}

variable "vault_int_ca_backend_path" {
  type = string
}

variable "vault_auth_backend_path" {
  type = string
}

variable "global_auth_namespace" {
  type = string
}

variable "global_auth_name" {
  type = string
}
