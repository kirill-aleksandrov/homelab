resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.name
  }
}

resource "helm_release" "operator" {
  name       = local.name
  repository = "https://helm.releases.hashicorp.com"
  chart      = local.name
  version    = "1.0.1"
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
