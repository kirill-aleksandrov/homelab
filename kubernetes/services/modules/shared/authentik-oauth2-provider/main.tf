locals {
  client_secret_field_name = "client_secret"
}

data "authentik_flow" "default_authentication" {
  slug = "default-authentication-flow"
}

data "authentik_flow" "default_authorization" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default_invalidation" {
  slug = "default-invalidation-flow"
}

data "authentik_certificate_key_pair" "default_signing" {
  name = "authentik Self-signed Certificate"
}

data "authentik_property_mapping_provider_scope" "scope_openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}

data "authentik_property_mapping_provider_scope" "scope_email" {
  managed = "goauthentik.io/providers/oauth2/scope-email"
}

data "authentik_property_mapping_provider_scope" "scope_profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}

resource "authentik_provider_oauth2" "provider" {
  name = var.name

  client_id     = var.name
  client_secret = "client_secret"

  signing_key = data.authentik_certificate_key_pair.default_signing.id

  authentication_flow = data.authentik_flow.default_authentication.id
  authorization_flow  = data.authentik_flow.default_authorization.id
  invalidation_flow   = data.authentik_flow.default_invalidation.id

  allowed_redirect_uris = [
    {
      url           = var.allowed_redirect_uri
      matching_mode = "strict"
    }
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope_openid.id,
    data.authentik_property_mapping_provider_scope.scope_email.id,
    data.authentik_property_mapping_provider_scope.scope_profile.id,
  ]

  lifecycle {
    ignore_changes = [client_secret]
  }
}

resource "authentik_application" "application" {
  name              = var.name
  slug              = var.name
  protocol_provider = authentik_provider_oauth2.provider.id
}

resource "vault_kv_secret_v2" "client_secret" {
  mount = var.vault_mount_path
  name  = "oauth2-provider"

  # Placeholder values
  # Secret will be created by terragrunt after hook
  data_json = jsonencode({
    "client-id"     = authentik_provider_oauth2.provider.client_id
    "client-secret" = "client-secret"
  })

  lifecycle {
    ignore_changes = [data_json]
  }
}

resource "vault_policy" "client_secret_read" {
  name   = "${var.vault_mount_path}-${vault_kv_secret_v2.client_secret.name}-read"
  policy = <<-EOT
    path "${var.vault_mount_path}/data/${vault_kv_secret_v2.client_secret.name}" {
      capabilities = ["read"]
    }
  EOT
}
