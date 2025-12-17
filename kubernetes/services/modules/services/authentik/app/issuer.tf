resource "kubernetes_service_account" "vault_issuer" {
  metadata {
    name      = "vault-issuer"
    namespace = var.namespace
  }
}

resource "kubernetes_role" "vault_issuer" {
  metadata {
    name      = "vault-issuer"
    namespace = var.namespace
  }

  rule {
    api_groups     = [""]
    resources      = ["serviceaccounts/token"]
    resource_names = [kubernetes_service_account.vault_issuer.metadata[0].name]
    verbs          = ["create"]
  }
}

resource "kubernetes_role_binding" "vault_issuer" {
  metadata {
    name      = "vault-issuer"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "vault-issuer"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cert-manager"
    namespace = "cert-manager"
  }
}

resource "vault_pki_secret_backend_role" "authentik" {
  backend                     = var.vault_int_ca_backend_path
  name                        = local.chart_name
  allowed_domains             = ["authentik.homelab"]
  allow_bare_domains          = true
  enforce_hostnames           = true
  allow_wildcard_certificates = false
  allow_localhost             = false
  allow_ip_sans               = false

  ttl      = 86400  #1d
  max_ttl  = 604800 #7d
  key_type = "ec"
  key_bits = 384

  use_csr_sans = true
  require_cn   = false
}

resource "vault_policy" "authentik_cert_create_policy" {
  name   = "cert-${local.chart_name}-sign"
  policy = <<-EOT
    path "${var.vault_int_ca_backend_path}/sign/${vault_pki_secret_backend_role.authentik.name}" {
      capabilities = ["update"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "authentik" {
  backend                          = "cert-manager"
  role_name                        = "authentik"
  bound_service_account_names      = [kubernetes_service_account.vault_issuer.metadata[0].name]
  bound_service_account_namespaces = [var.namespace]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.authentik_cert_create_policy.name]
  audience                         = "vault://${var.namespace}/${kubernetes_service_account.vault_issuer.metadata[0].name}"
}

resource "kubernetes_manifest" "vault_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "vault-issuer"
      namespace = var.namespace
    }
    spec = {
      vault = {
        path     = "${var.vault_int_ca_backend_path}/sign/${vault_pki_secret_backend_role.authentik.name}"
        server   = "https://vault.homelab"
        caBundle = base64encode(var.root_ca)
        auth = {
          kubernetes = {
            role      = vault_kubernetes_auth_backend_role.authentik.role_name
            mountPath = "/v1/auth/cert-manager"
            serviceAccountRef = {
              name = kubernetes_service_account.vault_issuer.metadata[0].name
            }
          }
        }
      }
    }
  }
}
