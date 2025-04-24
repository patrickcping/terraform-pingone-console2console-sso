data "pingone_environment" "rp_environment" {
  environment_id = var.rp_environment_id
}

resource "pingone_administrator_security" "rp_administrator_security" {
  environment_id = var.rp_environment_id

  authentication_method = var.rp_administrator_security_method
  mfa_status            = "ENFORCE"
  recovery              = true

  identity_provider = {
    id = pingone_identity_provider.pingone.id
  }

  lifecycle {
    precondition {
      condition     = contains([for service in data.pingone_environment.rp_environment.services : service.type], "MFA")
      error_message = format("The MFA service must be enabled for the provided relying party environment \"%s\" with ID \"%s\".", data.pingone_environment.rp_environment.name, data.pingone_environment.rp_environment.id)
    }
  }
}
