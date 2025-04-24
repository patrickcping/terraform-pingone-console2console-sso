resource "pingone_image" "pingone" {
  environment_id = var.rp_environment_id

  image_file_base64 = var.rp_idp_image_file_base64 != null ? var.rp_idp_image_file_base64 : filebase64(format("%s/image-logo.png", path.module))
}

resource "pingone_identity_provider" "pingone" {
  environment_id = var.rp_environment_id

  name        = var.rp_identity_provider_name
  description = var.rp_identity_provider_description
  enabled     = true

  icon = {
    id   = pingone_image.pingone.id
    href = pingone_image.pingone.uploaded_image.href
  }

  registration_population_id = var.rp_jit_provisioning_population_id

  openid_connect = {
    authorization_endpoint     = format("https://auth.%s/%s/as/authorize", var.op_base_domain, var.op_environment_id)
    client_id                  = pingone_application.op_application.id
    client_secret              = pingone_application_secret.op_application.secret
    discovery_endpoint         = format("https://auth.%s/%s/as/.well-known/openid-configuration", var.op_base_domain, var.op_environment_id)
    issuer                     = format("https://auth.%s/%s/as", var.op_base_domain, var.op_environment_id)
    jwks_endpoint              = format("https://auth.%s/%s/as/jwks", var.op_base_domain, var.op_environment_id)
    pkce_method                = "S256"
    scopes                     = ["address", "phone", "openid", "profile", "offline_access", "email"]
    token_endpoint             = format("https://auth.%s/%s/as/token", var.op_base_domain, var.op_environment_id)
    token_endpoint_auth_method = "CLIENT_SECRET_BASIC"
    userinfo_endpoint          = format("https://auth.%s/%s/as/userinfo", var.op_base_domain, var.op_environment_id)
  }
}

locals {
  sp_op_attribute_mappings = {
    "externalId" = {
      token_claim = "sub"
      update      = "EMPTY_ONLY"
    }
    "email" = {
      token_claim = "email"
      update      = "EMPTY_ONLY"
    }
    "name.family" = {
      token_claim = "family_name"
      update      = "EMPTY_ONLY"
    }
    "name.given" = {
      token_claim = "given_name"
      update      = "EMPTY_ONLY"
    }
    "username" = {
      token_claim = "username"
      update      = null
    }
  }
}

resource "pingone_identity_provider_attribute" "pingone" {
  for_each = local.sp_op_attribute_mappings

  environment_id       = var.rp_environment_id
  identity_provider_id = pingone_identity_provider.pingone.id

  name   = each.key
  update = each.value.update
  value  = format("$${providerAttributes.%s}", each.value.token_claim)
}