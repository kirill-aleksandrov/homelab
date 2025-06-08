locals {
  secret_path = "homelab-bind9"
  secret_name = "rfc2136-tsig"
  chart_name  = "external-dns"
}

resource "vault_mount" "bind9_mount" {
  path = local.secret_path
  type = "kv-v2"
  options = {
    version = "2"
  }
}

resource "vault_kv_secret_v2" "bind9_secret" {
  mount = vault_mount.bind9_mount.path
  name  = local.secret_name

  # Placeholder values
  # Secrets need to be provided after creation
  data_json = jsonencode({
    secret     = "secret"
    secret-alg = "secret-alg"
    keyname    = "keyname"
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}

resource "vault_policy" "bind9_read_policy" {
  name   = "${vault_kv_secret_v2.bind9_secret.mount}-${vault_kv_secret_v2.bind9_secret.name}-read"
  policy = <<-EOT
    path "${vault_kv_secret_v2.bind9_secret.mount}/data/${vault_kv_secret_v2.bind9_secret.name}" {
      capabilities = ["read", "list"]
    }
  EOT
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = local.chart_name
  }
}

resource "kubernetes_service_account" "vault_auth" {
  metadata {
    name      = "vault-auth"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
  }
}

resource "vault_kubernetes_auth_backend_role" "homelab_bind9" {
  backend                          = "vault-secrets-operator"
  role_name                        = local.secret_path
  bound_service_account_names      = [kubernetes_service_account.vault_auth.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace.external_dns.metadata[0].name]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.bind9_read_policy.name]
  audience                         = local.chart_name
}

resource "kubernetes_manifest" "vault_auth" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultAuth"

    metadata = {
      name      = "vault-auth"
      namespace = kubernetes_namespace.external_dns.metadata[0].name
    }

    spec = {
      # vaultAuthGlobalRef = "vault-secrets-operator/kubernetes-global-auth"
      vaultAuthGlobalRef = {
        name      = "kubernetes-global-auth"
        namespace = "vault-secrets-operator"
      }
      allowedNamespaces = [kubernetes_namespace.external_dns.metadata[0].name]
      kubernetes = {
        role           = vault_kubernetes_auth_backend_role.homelab_bind9.role_name
        serviceAccount = kubernetes_service_account.vault_auth.metadata[0].name
        audiences      = [local.chart_name]
      }
    }
  }
}

resource "kubernetes_manifest" "tsig_secret" {
  manifest = {
    apiVersion = "secrets.hashicorp.com/v1beta1"
    kind       = "VaultStaticSecret"

    metadata = {
      name      = local.secret_name
      namespace = kubernetes_namespace.external_dns.metadata[0].name
    }

    spec = {
      vaultAuthRef = kubernetes_manifest.vault_auth.manifest.metadata.name
      mount        = vault_mount.bind9_mount.path
      path         = vault_kv_secret_v2.bind9_secret.name
      type         = "kv-v2"
      destination = {
        name   = local.secret_name
        create = true
      }
    }
  }
}

resource "helm_release" "external_dns" {
  depends_on = [kubernetes_manifest.tsig_secret]

  name       = local.chart_name
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = local.chart_name
  version    = "1.16.1"
  namespace  = kubernetes_namespace.external_dns.metadata[0].name

  # Pod will not be ready until correct secret is set to vault
  wait = false

  values = [
    yamlencode({
      env = [
        {
          name = "EXTERNAL_DNS_RFC2136_TSIG_SECRET"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_manifest.tsig_secret.manifest.spec.destination.name
              key  = "secret"
            }
          }
        },
        {
          name = "EXTERNAL_DNS_RFC2136_TSIG_SECRET_ALG"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_manifest.tsig_secret.manifest.spec.destination.name
              key  = "secret-alg"
            }
          }
        },
        {
          name = "EXTERNAL_DNS_RFC2136_TSIG_KEYNAME"
          valueFrom = {
            secretKeyRef = {
              name = kubernetes_manifest.tsig_secret.manifest.spec.destination.name
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
        "--rfc2136-tsig-axfr"
      ]
    }
  ]
}
