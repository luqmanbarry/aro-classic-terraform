# external-secrets-config

This module configures shared External Secrets Operator settings.

For ARO, Azure Key Vault is the default secret backend in this repo.

Use it for:

- `ExternalSecretsConfig`
- shared `ClusterSecretStore` objects
- one shared default `ClusterSecretStore` name for the cluster

Do not use this module as the normal place for app `ExternalSecret` objects.

Normal app secrets should stay with the app that uses them.

## Default Provider

The default pattern is:

- Azure Key Vault
- one shared `ClusterSecretStore` called `platform-secrets`
- app `ExternalSecret` objects that read from that shared store
- the chart fails fast if enabled provider values still use placeholders

The sample values file in `clusters/dev/aroclassic101/values/external-secrets-config.yaml` already shows the Azure Key Vault shape.

## Other Provider Examples

Provider example snippets are in:

- [examples/README.md](./examples/README.md)
- [examples/ibm-cloud-secrets-manager.yaml](./examples/ibm-cloud-secrets-manager.yaml)
- [examples/hashicorp-vault.yaml](./examples/hashicorp-vault.yaml)
- [examples/aws-secrets-manager.yaml](./examples/aws-secrets-manager.yaml)
- [examples/azure-key-vault.yaml](./examples/azure-key-vault.yaml)
- [examples/google-secret-manager.yaml](./examples/google-secret-manager.yaml)
- [examples/cyberark-conjur.yaml](./examples/cyberark-conjur.yaml)

Copy one example into `clusters/<group-path>/<cluster>/values/external-secrets-config.yaml` only if your platform does not use Azure Key Vault.

The other provider examples are optional references.

Use one shared `ClusterSecretStore` name, such as `platform-secrets`, and make app `ExternalSecret` objects reference that same name.
