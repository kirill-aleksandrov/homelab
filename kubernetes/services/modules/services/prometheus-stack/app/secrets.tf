resource "kubernetes_service_account" "vault_auth" {
  metadata {
    name      = "vault-auth"
    namespace = kubernetes_namespace.chart_namespace.metadata[0].name
  }
}

resource "vault_kubernetes_auth_backend_role" "prometheus_stack" {
  backend                          = var.vault_auth_backend_path
  role_name                        = "prometheus-stack"
  bound_service_account_names      = [kubernetes_service_account.vault_auth.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace.chart_namespace.metadata[0].name]
  token_ttl                        = 3600
  token_policies = [
    var.vault_prometheus_client_secret_read_policy_name,
    var.vault_prometheus_cookie_secret_read_policy_name,
    var.vault_alertmanager_client_secret_read_policy_name,
    var.vault_alertmanager_cookie_secret_read_policy_name,
    var.vault_grafana_client_secret_read_policy_name,
  ]
  audience = local.chart_name
}

resource "kubernetes_manifest" "vault_auth" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultAuth"

    metadata = {
      name      = "vault-auth"
      namespace = kubernetes_namespace.chart_namespace.metadata[0].name
    }

    spec = {
      vaultAuthGlobalRef = {
        name      = var.vault_global_auth_name
        namespace = var.vault_global_auth_namespace
      }
      allowedNamespaces = [kubernetes_namespace.chart_namespace.metadata[0].name]
      kubernetes = {
        role           = vault_kubernetes_auth_backend_role.prometheus_stack.role_name
        serviceAccount = kubernetes_service_account.vault_auth.metadata[0].name
        audiences      = [local.chart_name]
      }
    }
  }
}

resource "kubernetes_manifest" "prometheus_client_secret" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultStaticSecret"

    metadata = {
      name      = "prometheus-oauth-provider-client-secret"
      namespace = kubernetes_namespace.chart_namespace.metadata[0].name
    }

    spec = {
      vaultAuthRef = kubernetes_manifest.vault_auth.manifest.metadata.name
      mount        = var.vault_prometheus_mount_path
      path         = var.vault_prometheus_client_secret_secret_name
      type         = "kv-v2"
      destination = {
        name   = "prometheus-oauth-provider-client-secret"
        create = true
      }
    }
  }
}

resource "kubernetes_manifest" "prometheus_cookie_secret" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultStaticSecret"

    metadata = {
      name      = "prometheus-oauth-proxy-cookie-secret"
      namespace = kubernetes_namespace.chart_namespace.metadata[0].name
    }

    spec = {
      vaultAuthRef = kubernetes_manifest.vault_auth.manifest.metadata.name
      mount        = var.vault_prometheus_mount_path
      path         = var.vault_prometheus_cookie_secret_secret_name
      type         = "kv-v2"
      destination = {
        name   = "prometheus-oauth-proxy-cookie-secret"
        create = true
      }
    }
  }
}

resource "kubernetes_manifest" "alertmanager_client_secret" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultStaticSecret"

    metadata = {
      name      = "alertmanager-oauth-provider-client-secret"
      namespace = kubernetes_namespace.chart_namespace.metadata[0].name
    }

    spec = {
      vaultAuthRef = kubernetes_manifest.vault_auth.manifest.metadata.name
      mount        = var.vault_alertmanager_mount_path
      path         = var.vault_alertmanager_client_secret_secret_name
      type         = "kv-v2"
      destination = {
        name   = "alertmanager-oauth-provider-client-secret"
        create = true
      }
    }
  }
}

resource "kubernetes_manifest" "alertmanager_cookie_secret" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultStaticSecret"

    metadata = {
      name      = "alertmanager-oauth-proxy-cookie-secret"
      namespace = kubernetes_namespace.chart_namespace.metadata[0].name
    }

    spec = {
      vaultAuthRef = kubernetes_manifest.vault_auth.manifest.metadata.name
      mount        = var.vault_alertmanager_mount_path
      path         = var.vault_alertmanager_cookie_secret_secret_name
      type         = "kv-v2"
      destination = {
        name   = "alertmanager-oauth-proxy-cookie-secret"
        create = true
      }
    }
  }
}

resource "kubernetes_manifest" "grafana_client_secret" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultStaticSecret"

    metadata = {
      name      = "grafana-oauth-provider-client-secret"
      namespace = kubernetes_namespace.chart_namespace.metadata[0].name
    }

    spec = {
      vaultAuthRef = kubernetes_manifest.vault_auth.manifest.metadata.name
      mount        = var.vault_grafana_mount_path
      path         = var.vault_grafana_client_secret_secret_name
      type         = "kv-v2"
      destination = {
        name   = "grafana-oauth-provider-client-secret"
        create = true
      }
    }
  }
}
