variable "rp_environment_id" {
  type = string
}

variable "rp_base_domain" {
  type = string
}

variable "rp_jit_provisioning_population_id" {
  type = string
}

variable "rp_identity_provider_name" {
  type    = string
  default = "PingOne OP"
}

variable "rp_identity_provider_description" {
  type    = string
  default = null
}

variable "rp_administrator_security_method" {
  type    = string
  default = "EXTERNAL"
}

variable "rp_idp_image_file_base64" {
  type    = string
  default = null
}