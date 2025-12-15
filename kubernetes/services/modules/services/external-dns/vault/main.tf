locals {
  secret_path = "homelab-bind9"
  secret_name = "rfc2136-tsig"
  chart_name  = "external-dns"
}

resource "kubernetes_service_account" "vault_auth" {
  metadata {
    name      = "vault-auth"
    namespace = var.namespace
  }
}

resource "vault_kubernetes_auth_backend_role" "homelab_bind9" {
  backend                          = "vault-secrets-operator"
  role_name                        = local.secret_path
  bound_service_account_names      = [kubernetes_service_account.vault_auth.metadata[0].name]
  bound_service_account_namespaces = [var.namespace]
  token_ttl                        = 3600
  token_policies                   = [var.vault_tsig_read_policy_name]
  audience                         = local.chart_name
}

resource "kubernetes_manifest" "vault_auth" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultAuth"

    metadata = {
      name      = "vault-auth"
      namespace = var.namespace
    }

    spec = {
      vaultAuthGlobalRef = {
        name      = var.global_auth_name
        namespace = var.global_auth_namespace
      }
      allowedNamespaces = [var.namespace]
      kubernetes = {
        role           = vault_kubernetes_auth_backend_role.homelab_bind9.role_name
        serviceAccount = kubernetes_service_account.vault_auth.metadata[0].name
        audiences      = [local.chart_name]
      }
    }
  }
}

resource "kubernetes_manifest" "tsig_secret" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultStaticSecret"

    metadata = {
      name      = local.secret_name
      namespace = var.namespace
    }

    spec = {
      vaultAuthRef = kubernetes_manifest.vault_auth.manifest.metadata.name
      mount        = var.vault_tsig_mount_path
      path         = var.vault_tsig_secret_name
      type         = "kv-v2"
      destination = {
        name   = local.secret_name
        create = true
      }
    }
  }
}
