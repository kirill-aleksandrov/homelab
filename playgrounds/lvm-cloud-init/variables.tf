variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_username" {
  type = string
}

variable "proxmox_password" {
  type      = string
  sensitive = true
}

variable "proxmox_insecure" {
  type    = bool
  default = false
}

variable "dns_server" {
  type = string
}

variable "dns_key_name" {
  type = string
}

variable "dns_key_algorithm" {
  type = string
}

variable "dns_key_secret" {
  type      = string
  sensitive = true
}

variable "dns_zone" {
  type = string
}

variable "dns_ttl" {
  type    = number
  default = 300
}

variable "vm_ubuntu_image_url" {
  type = string
}

variable "vm_username" {
  type = string
}

variable "vm_password_hash" {
  type = string
}
