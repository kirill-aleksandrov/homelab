locals {
  root_ca                     = jsondecode(run_cmd("--terragrunt-quiet", "curl", "-s", "${get_env("VAULT_ADDR")}/v1/homelab-root-ca/cert/ca_chain")).data.certificate
  vault_tsig_read_policy_name = "homelab-bind9-rfc2136-tsig-read"
  vault_tsig_mount_path       = "homelab-bind9"
  vault_tsig_secret_name      = "rfc2136-tsig"
  vault_int_ca_backend_path   = "homelab-int-ca"
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
  EOF
}
