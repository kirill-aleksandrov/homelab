resource "vault_policy" "secret_key_read" {
  name   = "${var.vault_secret_key_mount_path}-${var.vault_secret_key_secret_name}-read"
  policy = <<-EOT
    path "${var.vault_secret_key_mount_path}/data/${var.vault_secret_key_secret_name}" {
      capabilities = ["read", "list"]
    }
  EOT
}

resource "kubernetes_service_account" "vault_auth" {
  metadata {
    name      = "vault-auth"
    namespace = var.namespace
  }
}

resource "vault_kubernetes_auth_backend_role" "authentik_role" {
  backend                          = var.vault_auth_backend_path
  role_name                        = "authentik"
  bound_service_account_names      = [kubernetes_service_account.vault_auth.metadata[0].name]
  bound_service_account_namespaces = [var.namespace]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.secret_key_read.name]
  audience                         = var.namespace
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
        role           = vault_kubernetes_auth_backend_role.authentik_role.role_name
        serviceAccount = kubernetes_service_account.vault_auth.metadata[0].name
        audiences      = [var.namespace]
      }
    }
  }
}

resource "kubernetes_manifest" "secret_key" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultStaticSecret"

    metadata = {
      name      = "secret-key"
      namespace = var.namespace
    }

    spec = {
      vaultAuthRef = kubernetes_manifest.vault_auth.manifest.metadata.name
      mount        = var.vault_secret_key_mount_path
      path         = var.vault_secret_key_secret_name
      type         = "kv-v2"
      destination = {
        name   = "secret-key"
        create = true
      }
    }
  }
}
