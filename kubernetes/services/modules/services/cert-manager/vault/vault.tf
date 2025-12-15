resource "vault_auth_backend" "cert_manager" {
  type = "kubernetes"
  path = "cert-manager"
}

resource "kubernetes_service_account" "token_reviewer_service_account" {
  metadata {
    name      = "cert-manager-token-reviewer"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding" "token_reviewer_service_account" {
  metadata {
    name = "cert-manager-${kubernetes_service_account.token_reviewer_service_account.metadata[0].name}"
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

