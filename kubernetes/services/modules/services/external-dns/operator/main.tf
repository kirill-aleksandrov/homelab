locals {
  chart_name = "external-dns"
}

resource "helm_release" "external_dns" {
  name       = local.chart_name
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = local.chart_name
  version    = "1.19.0"
  namespace  = var.namespace

  values = [
    yamlencode({
      env = [
        {
          name = "EXTERNAL_DNS_RFC2136_TSIG_SECRET"
          valueFrom = {
            secretKeyRef = {
              name = var.tsig_secret_name
              key  = "secret"
            }
          }
        },
        {
          name = "EXTERNAL_DNS_RFC2136_TSIG_SECRET_ALG"
          valueFrom = {
            secretKeyRef = {
              name = var.tsig_secret_name
              key  = "secret-alg"
            }
          }
        },
        {
          name = "EXTERNAL_DNS_RFC2136_TSIG_KEYNAME"
          valueFrom = {
            secretKeyRef = {
              name = var.tsig_secret_name
              key  = "keyname"
            }
          }
        }
      ]
    })
  ]

  set = [
    {
      name  = "provider.name"
      value = "rfc2136"
    },
    {
      name  = "txtPrefix"
      value = "${local.chart_name}-"
    },
    {
      name  = "txtOwnerId"
      value = "kubernetes"
    },
  ]

  set_list = [
    {
      name = "extraArgs"
      value = [
        "--rfc2136-host=172.16.0.2",
        "--rfc2136-port=53",
        "--rfc2136-zone=homelab",
      ]
    }
  ]
}
