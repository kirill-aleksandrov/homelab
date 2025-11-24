resource "helm_release" "operator" {
  name       = local.name
  repository = "oci://quay.io/jetstack/charts"
  chart      = local.name
  version    = "v1.19.1"
  namespace  = kubernetes_namespace.namespace.metadata[0].name

  set = [
    {
      name  = "crds.enabled"
      value = true
    }
  ]
}
