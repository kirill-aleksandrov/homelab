locals {
  name = "vault-secrets-operator"
}

resource "vault_auth_backend" "vault_auth_backend" {
  type = "kubernetes"
  path = local.name
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.name
  }
}

resource "helm_release" "operator" {
  name       = local.name
  repository = "https://helm.releases.hashicorp.com"
  chart      = local.name
  version    = "0.10.0"
  namespace  = kubernetes_namespace.namespace.metadata[0].name

  set = [
    {
      name  = "controller.securityContext.seccompProfile.type"
      value = "RuntimeDefault"
    }
  ]

  set_list = [
    {
      name  = "controller.securityContext.capabilities.drop"
      value = ["ALL"]
    }
  ]
}

resource "kubernetes_service_account" "token_reviewer_service_account" {
  metadata {
    name      = "token-reviewer"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "token_reviewer_service_account" {
  metadata {
    name = "${local.name}-${kubernetes_service_account.token_reviewer_service_account.metadata[0].name}"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.token_reviewer_service_account.metadata[0].name
    namespace = kubernetes_namespace.namespace.metadata[0].name
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
    namespace = kubernetes_namespace.namespace.metadata[0].name
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
      namespace = kubernetes_namespace.namespace.metadata[0].name
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
      namespace = kubernetes_namespace.namespace.metadata[0].name
    }

    spec = {
      allowedNamespaces  = ["*"]
      vaultConnectionRef = "${kubernetes_namespace.namespace.metadata[0].name}/${kubernetes_manifest.global_connection.manifest.metadata.name}"
      defaultAuthMethod  = "kubernetes"
      defaultMount       = vault_auth_backend.vault_auth_backend.path
      kubernetes = {
        mount = vault_auth_backend.vault_auth_backend.path
      }
    }
  }
}
