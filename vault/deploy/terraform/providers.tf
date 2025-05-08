terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.0"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "3.4.3"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = var.proxmox_insecure
}

provider "dns" {
  update {
    server        = var.dns_server
    key_name      = var.dns_key_name
    key_algorithm = var.dns_key_algorithm
    key_secret    = var.dns_key_secret
  }
}

