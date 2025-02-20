terraform {
  required_providers {
    pingone = {
      source                = "pingidentity/pingone"
      version               = ">= 1.4.0, < 2.0.0"
      configuration_aliases = [pingone.op]
    }
  }
}
