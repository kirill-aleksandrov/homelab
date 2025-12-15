locals {
  chart_name = "topolvm"
}

resource "kubernetes_namespace" "topolvm" {
  metadata {
    name = local.chart_name

    labels = {
      "pod-security.kubernetes.io/enforce"         = "privileged"
      "pod-security.kubernetes.io/enforce-version" = "v1.33"
      "pod-security.kubernetes.io/audit"           = "privileged"
      "pod-security.kubernetes.io/warn"            = "privileged"
    }
  }
}

resource "helm_release" "topolvm" {
  name       = local.chart_name
  repository = "https://topolvm.github.io/topolvm"
  chart      = local.chart_name
  version    = "15.7.1"
  namespace  = kubernetes_namespace.topolvm.metadata[0].name

  values = [
    yamlencode({
      lvmd = {
        deviceClasses = [
          {
            name         = "sata-ssd"
            volume-group = "kubernetes"
            default      = true
            spare-gb     = 50
          }
        ]
      }
    })
  ]
}
