locals {
  root_ca                   = jsondecode(run_cmd("--terragrunt-quiet", "curl", "-s", "${get_env("VAULT_ADDR")}/v1/homelab-root-ca/cert/ca_chain")).data.certificate
  vault_address             = get_env("VAULT_ADDR")
  vault_int_ca_backend_path = "homelab-int-ca"
  authentik_url             = "https://authentik.homelab"
  authentik_token           = run_cmd("--terragrunt-quiet", "vault", "kv", "get", "-field=token", "authentik/token")
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    terraform {
      required_providers {
        vault = {
          source  = "hashicorp/vault"
          version = "5.6.0"
        }
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "2.38.0"
        }
        helm = {
          source  = "hashicorp/helm"
          version = "3.0.2"
        }
        authentik = {
          source  = "goauthentik/authentik"
          version = "2025.10.1"
        }
      }
    }

    provider "kubernetes" {
      config_path = "~/.kube/config"
    }

    provider "helm" {
      kubernetes = {
        config_path = "~/.kube/config"
      }
    }

    provider "authentik" {
      url   = var.authentik_url
      token = var.authentik_token
    }
  EOF
}
