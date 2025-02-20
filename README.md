# terraform-pingone-console2console-sso

A module that configures SSO between two PingOne Consoles using OpenID Connect.

Typical use case is managing admin access to multiple PingOne tenants from a central tenant.

Two instances of PingOne are configured in this module.

* The "PingOne OP" instance (in it's Identity Provider role) is the PingOne tenant that acts as the "OpenID Connect Provider". The PingOne OP uses the `pingone.op` provider alias.
* The "PingOne RP" instance (in it's relying party role) is the PingOne tenant that acts as the service provider, outsourcing it's authentication to the "PingOne OP". The PingOne RP uses the default `pingone` provider alias.
