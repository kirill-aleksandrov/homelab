resource "helm_release" "prometheus_stack" {
  name       = local.chart_name
  repository = "oci://ghcr.io/prometheus-community/charts"
  chart      = local.chart_name
  version    = "79.7.1"
  namespace  = kubernetes_namespace.chart_namespace.metadata[0].name

  values = [
    yamlencode({
      prometheus-node-exporter = {
        namespaceOverride = kubernetes_namespace.node_exporter_namespace.metadata[0].name
      }
      prometheus = {
        ingress = {
          enabled = false
        }
      }
      alertmanager = {
        ingress = {
          enabled = false
        }
      }
      grafana = {
        extraConfigmapMounts = [
          {
            name      = "root-ca"
            mountPath = "/etc/grafana/ssl/"
            configMap = kubernetes_manifest.root_ca_configmap.manifest.metadata.name
            readOnly  = true
          }
        ]
        extraSecretMounts = [
          {
            name        = "oauth2-secret"
            secretName  = kubernetes_manifest.grafana_client_secret.manifest.spec.destination.name
            defaultMode = "0440"
            mountPath   = "/etc/secrets/oauth2"
            readOnly    = true
          },
        ]
        "grafana.ini" = {
          server = {
            root_url = "https://grafana.homelab"
          }
          auth = {
            signout_redirect_url = "https://authentik.homelab/application/o/${var.oauth2_grafana_application_slug}/end-session/"
          }
          "auth.generic_oauth" = {
            name          = "authentik"
            enabled       = true
            tls_client_ca = "/etc/grafana/ssl/root-ca.pem"
            client_id     = "$__file{/etc/secrets/oauth2/client-id}"
            client_secret = "$__file{/etc/secrets/oauth2/client-secret}"
            scopes        = "openid email profile"
            auth_url      = "https://authentik.homelab/application/o/authorize/"
            token_url     = "https://authentik.homelab/application/o/token/"
            api_url       = "https://authentik.homelab/application/o/userinfo/"
            # role_attribute_path = "contains(groups, 'Grafana Admins') && 'Admin' || contains(groups, 'Grafana Editors') && 'Editor' || 'Viewer'"
          }
        }
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hosts = [
            "grafana.homelab"
          ]
          annotations = {
            "cert-manager.io/issuer"                = module.grafana_issuer.issuer_name
            "cert-manager.io/private-key-algorithm" = "ECDSA"
            "cert-manager.io/private-key-size"      = "384"
          }
          tls = [
            {
              hosts      = ["grafana.homelab"]
              secretName = "grafana-cert"
            }
          ]
        }
      }
    })
  ]
}
