
resource "kubernetes_manifest" "root_ca_configmap" {
  manifest = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "root-ca"
      namespace = kubernetes_namespace.chart_namespace.metadata[0].name
    }
    data = {
      "root-ca.pem" = var.root_ca
    }
  }
}

resource "helm_release" "prometheus_oauth2_proxy" {
  name       = "oauth2-proxy-prometheus"
  repository = "https://oauth2-proxy.github.io/manifests"
  chart      = "oauth2-proxy"
  version    = "10.0.0"
  namespace  = kubernetes_namespace.chart_namespace.metadata[0].name

  values = [
    yamlencode({
      proxyVarsAsSecrets = false

      extraArgs = {
        provider            = "oidc"
        oidc-issuer-url     = "${var.authentik_url}/application/o/${var.oauth2_prometheus_application_slug}/"
        email-domain        = "*"
        upstream            = "http://kube-prometheus-stack-prometheus:9090"
        show-debug-on-error = true

        # my homelab doesn't have an email server
        insecure-oidc-allow-unverified-email = true
      }

      extraEnv = [
        {
          name = "OAUTH2_PROXY_CLIENT_ID"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_manifest.prometheus_client_secret.manifest.spec.destination.name
              key  = "client-id"
            }
          }
        },
        {
          name = "OAUTH2_PROXY_CLIENT_SECRET"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_manifest.prometheus_client_secret.manifest.spec.destination.name
              key  = "client-secret"
            }
          }
        },
        {
          name = "OAUTH2_PROXY_COOKIE_SECRET"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_manifest.prometheus_cookie_secret.manifest.spec.destination.name
              key  = "cookie-secret"
            }
          }
        },
      ]

      extraVolumes = [
        {
          name = "root-ca"
          configMap = {
            name = kubernetes_manifest.root_ca_configmap.manifest.metadata.name
            items = [
              {
                key  = "root-ca.pem"
                path = "root-ca.pem"
              }
            ]
          }
        }
      ]

      extraVolumeMounts = [
        {
          mountPath = "/etc/ssl/certs/"
          name      = "root-ca"
        }
      ]

      ingress = {
        enabled   = true
        className = "nginx"
        hosts     = ["prometheus.homelab"]
        annotations = {
          "cert-manager.io/issuer"                = module.prometheus_issuer.issuer_name
          "cert-manager.io/private-key-algorithm" = "ECDSA"
          "cert-manager.io/private-key-size"      = "384"
        }
        tls = [
          {
            hosts      = ["prometheus.homelab"]
            secretName = "prometheus-cert"
          }
        ]
      }
    })
  ]
}

resource "helm_release" "alertmanager_oauth2_proxy" {
  name       = "oauth2-proxy-alertmanager"
  repository = "https://oauth2-proxy.github.io/manifests"
  chart      = "oauth2-proxy"
  version    = "10.0.0"
  namespace  = kubernetes_namespace.chart_namespace.metadata[0].name

  values = [
    yamlencode({
      proxyVarsAsSecrets = false

      extraArgs = {
        provider            = "oidc"
        oidc-issuer-url     = "${var.authentik_url}/application/o/${var.oauth2_alertmanager_application_slug}/"
        email-domain        = "*"
        upstream            = "http://kube-prometheus-stack-alertmanager:9093"
        show-debug-on-error = true

        # my homelab doesn't have an email server
        insecure-oidc-allow-unverified-email = true
      }

      extraEnv = [
        {
          name = "OAUTH2_PROXY_CLIENT_ID"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_manifest.alertmanager_client_secret.manifest.spec.destination.name
              key  = "client-id"
            }
          }
        },
        {
          name = "OAUTH2_PROXY_CLIENT_SECRET"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_manifest.alertmanager_client_secret.manifest.spec.destination.name
              key  = "client-secret"
            }
          }
        },
        {
          name = "OAUTH2_PROXY_COOKIE_SECRET"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_manifest.alertmanager_cookie_secret.manifest.spec.destination.name
              key  = "cookie-secret"
            }
          }
        },
      ]

      extraVolumes = [
        {
          name = "root-ca"
          configMap = {
            name = kubernetes_manifest.root_ca_configmap.manifest.metadata.name
            items = [
              {
                key  = "root-ca.pem"
                path = "root-ca.pem"
              }
            ]
          }
        }
      ]

      extraVolumeMounts = [
        {
          mountPath = "/etc/ssl/certs/"
          name      = "root-ca"
        }
      ]

      ingress = {
        enabled   = true
        className = "nginx"
        hosts     = ["alertmanager.homelab"]
        annotations = {
          "cert-manager.io/issuer"                = module.alertmanager_issuer.issuer_name
          "cert-manager.io/private-key-algorithm" = "ECDSA"
          "cert-manager.io/private-key-size"      = "384"
        }
        tls = [
          {
            hosts      = ["alertmanager.homelab"]
            secretName = "alertmanager-cert"
          }
        ]
      }
    })
  ]
}
