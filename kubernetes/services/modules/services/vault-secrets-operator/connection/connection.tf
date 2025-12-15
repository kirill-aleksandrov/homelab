
resource "vault_auth_backend" "vault_auth_backend" {
  type = "kubernetes"
  path = local.name
}

resource "kubernetes_service_account" "token_reviewer_service_account" {
  metadata {
    name      = "token-reviewer"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding" "token_reviewer_service_account" {
  metadata {
    name = "${local.name}-${kubernetes_service_account.token_reviewer_service_account.metadata[0].name}"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.token_reviewer_service_account.metadata[0].name
    namespace = var.namespace
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_secret" "root-ca" {
  metadata {
    name      = "root-ca"
    namespace = var.namespace
  }

  data = {
    "ca.crt" = var.root_ca
  }
}

resource "kubernetes_manifest" "global_connection" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultConnection"

    metadata = {
      name      = "global-connection"
      namespace = var.namespace
    }

    spec = {
      address         = "https://vault.homelab"
      caCertSecretRef = "root-ca"
    }
  }
}


resource "kubernetes_manifest" "global_auth" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultAuthGlobal"

    metadata = {
      name      = "kubernetes-global-auth"
      namespace = var.namespace
    }

    spec = {
      allowedNamespaces  = ["*"]
      vaultConnectionRef = "${var.namespace}/${kubernetes_manifest.global_connection.manifest.metadata.name}"
      defaultAuthMethod  = "kubernetes"
      defaultMount       = vault_auth_backend.vault_auth_backend.path
      kubernetes = {
        mount = vault_auth_backend.vault_auth_backend.path
      }
    }
  }
}
