terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.3.0"
    }
  }
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}
