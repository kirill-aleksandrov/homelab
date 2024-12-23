terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.5.0"
    }
  }
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}
