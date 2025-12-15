resource "vault_mount" "authentik" {
  path = local.chart_name
  type = "kv-v2"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_v2" "authentik" {
  mount = vault_mount.authentik.path
  name  = local.chart_name

  # Placeholder values
  # Secrets need to be provided after creation
  data_json = jsonencode({
    "secret-key" = "secret"
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}

resource "vault_policy" "authentik_read" {
  name   = "${vault_kv_secret_v2.authentik.mount}-${vault_kv_secret_v2.authentik.name}-read"
  policy = <<-EOT
    path "${vault_kv_secret_v2.authentik.mount}/data/${vault_kv_secret_v2.authentik.name}" {
      capabilities = ["read", "list"]
    }
  EOT
}

resource "kubernetes_service_account" "vault_auth" {
  metadata {
    name      = "vault-auth"
    namespace = kubernetes_namespace.authentik.metadata[0].name
  }
}

resource "vault_kubernetes_auth_backend_role" "homelab_bind9" {
  backend                          = "vault-secrets-operator"
  role_name                        = local.chart_name
  bound_service_account_names      = [kubernetes_service_account.vault_auth.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace.authentik.metadata[0].name]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.authentik_read.name]
  audience                         = local.chart_name
}

resource "kubernetes_manifest" "vault_auth" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultAuth"

    metadata = {
      name      = "vault-auth"
      namespace = kubernetes_namespace.authentik.metadata[0].name
    }

    spec = {
      vaultAuthGlobalRef = {
        name      = "kubernetes-global-auth"
        namespace = "vault-secrets-operator"
      }
      allowedNamespaces = [kubernetes_namespace.authentik.metadata[0].name]
      kubernetes = {
        role           = vault_kubernetes_auth_backend_role.homelab_bind9.role_name
        serviceAccount = kubernetes_service_account.vault_auth.metadata[0].name
        audiences      = [local.chart_name]
      }
    }
  }
}

resource "kubernetes_manifest" "secret_key" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultStaticSecret"

    metadata = {
      name      = local.chart_name
      namespace = kubernetes_namespace.authentik.metadata[0].name
    }

    spec = {
      vaultAuthRef = kubernetes_manifest.vault_auth.manifest.metadata.name
      mount        = vault_mount.authentik.path
      path         = vault_kv_secret_v2.authentik.name
      type         = "kv-v2"
      destination = {
        name   = "${local.chart_name}-secret-key"
        create = true
      }
    }
  }
}
