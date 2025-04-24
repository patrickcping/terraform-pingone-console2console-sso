resource "pingone_image" "op_application" {
  provider = pingone.op

  environment_id = var.op_environment_id

  image_file_base64 = var.op_application_image_file_base64 != null ? var.op_application_image_file_base64 : filebase64(format("%s/image-logo.png", path.module))
}

resource "pingone_application" "op_application" {
  provider = pingone.op

  environment_id = var.op_environment_id
  name           = var.op_application_name
  description    = var.op_application_description
  enabled        = true

  icon = {
    id   = pingone_image.op_application.id
    href = pingone_image.op_application.uploaded_image.href
  }

  hidden_from_app_portal = false

  oidc_options = {
    type                       = "WEB_APP"
    grant_types                = ["AUTHORIZATION_CODE", "REFRESH_TOKEN"]
    response_types             = ["CODE"]
    token_endpoint_auth_method = "CLIENT_SECRET_BASIC"
    pkce_enforcement           = "S256_REQUIRED"
    redirect_uris              = [format("https://auth.%s/%s/rp/callback/openid_connect", var.rp_base_domain, var.rp_environment_id)]
    initiate_login_uri         = format("https://console.%s/?env=%s", var.rp_base_domain, var.rp_environment_id)
    target_link_uri            = format("https://console.%s/?env=%s", var.rp_base_domain, var.rp_environment_id)
  }

  access_control_group_options = {
    groups = var.op_application_group_access_ids
    type   = "ANY_GROUP"
  }
}

resource "time_rotating" "op_application_secret_rotation" {
  rotation_days = 30
}

resource "pingone_application_secret" "op_application" {
  provider = pingone.op

  environment_id = var.op_environment_id
  application_id = pingone_application.op_application.id

  regenerate_trigger_values = {
    "rotation_rfc3339" : time_rotating.op_application_secret_rotation.rotation_rfc3339,
  }
}

locals {
  op_application_attribute_mappings = {
    "sub" = {
      user_field = "id"
      required   = true
    }
    "email" = {
      user_field = "email"
      required   = true
    }
    "email_verified" = {
      user_field = "emailVerified"
      required   = true
    }
    "family_name" = {
      user_field = "name.family"
      required   = false
    }
    "given_name" = {
      user_field = "name.given"
      required   = false
    }
    "username" = {
      user_field = "username"
      required   = true
    }
  }
}

resource "pingone_application_attribute_mapping" "op_application" {
  provider = pingone.op

  for_each = local.op_application_attribute_mappings

  environment_id = var.op_environment_id
  application_id = pingone_application.op_application.id

  name     = each.key
  value    = format("$${user.%s}", each.value.user_field)
  required = each.value.required
}
