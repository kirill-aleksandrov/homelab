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

variable "vm_alpine_image_url" {
  type = string
}

variable "vm_username" {
  type = string
}

variable "vm_password_hash" {
  type = string
}
