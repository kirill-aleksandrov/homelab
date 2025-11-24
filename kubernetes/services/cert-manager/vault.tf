resource "vault_auth_backend" "cert_manager" {
  type = "kubernetes"
  path = "cert-manager"
}

resource "kubernetes_service_account" "token_reviewer_service_account" {
  metadata {
    name      = "cert-manager-token-reviewer"
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

