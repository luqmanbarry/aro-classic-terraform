# Identity Providers

Configures OpenShift OAuth identity providers and their client secrets.

Safe defaults:

- OpenID provider support is off by default
- no provider renders unless it is explicitly enabled
- the chart fails fast if enabled providers still use placeholder client IDs or issuer URLs
- client secrets come from Azure Key Vault through External Secrets Operator

Use this chart only after the identity team has approved the issuer, client app, and group claim model.
