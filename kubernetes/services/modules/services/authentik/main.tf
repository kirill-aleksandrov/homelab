locals {
  secret_volumes = [
    {
      name = "postgres-creds"
      secret = {
        secretName = "postgres-app"
      }
    },
    {
      name = "secret-key",
      secret = {
        secretName = "${local.chart_name}-secret-key"
      }
    }
  ]
  secret_volume_mounts = [
    {
      name      = "postgres-creds"
      mountPath = "/postgres-creds"
      readOnly  = true
    },
    {
      name      = "secret-key"
      mountPath = "/secret-key"
      readOnly  = true
    }
  ]
  container_security_context = {
    allowPrivilegeEscalation = false
    runAsNonRoot             = true
    capabilities = {
      drop = ["ALL"]
    }
    seccompProfile = {
      type = "RuntimeDefault"
    }
  }
  redis_persistence = {
    enabled : true
    storageClass : "topolvm-provisioner"
    size : "1Gi"
  }
}

resource "helm_release" "authentik" {
  depends_on = [kubernetes_manifest.postgres]

  name       = local.chart_name
  repository = "https://charts.goauthentik.io"
  chart      = local.chart_name
  version    = "2025.10.2"
  namespace  = kubernetes_namespace.authentik.metadata[0].name

  values = [
    yamlencode({
      authentik = {
        secret_key = "file:///secret-key/secret-key"
        postgresql = {
          host     = "postgres-rw"
          user     = "file:///postgres-creds/username"
          password = "file:///postgres-creds/password"
        }
      }
      server = {
        ingress = {
          enabled          = true
          ingressClassName = "nginx"
          hosts = [
            "authentik.homelab"
          ]
          annotations = {
            "cert-manager.io/issuer"                = kubernetes_manifest.vault_issuer.manifest.metadata.name,
            "cert-manager.io/private-key-algorithm" = "ECDSA"
            "cert-manager.io/private-key-size"      = "384"
          }
          tls = [
            {
              hosts      = ["authentik.homelab"]
              secretName = "authentik-cert"
            }
          ]
        }
        volumes                  = local.secret_volumes
        volumeMounts             = local.secret_volume_mounts
        containerSecurityContext = local.container_security_context
      }
      worker = {
        volumes                  = local.secret_volumes
        volumeMounts             = local.secret_volume_mounts
        containerSecurityContext = local.container_security_context
      }
    })
  ]
}
