# Image Registry Allow And Deny

Controls allowed image sources and trusted registry certificates for ARO.

Safe defaults:

- the chart fails fast if cluster name or Key Vault inputs still use placeholder values
- the allow list is small and explicit
- registry certificates must come from Azure Key Vault through `ExternalSecret`

Before you enable this chart:

1. Set real values in `clusters/<group-path>/<cluster>/values/image-registry-allow-deny.yaml`.
2. Review the allow list for your platform and workload registries.
3. Add any custom registry CA secrets to Azure Key Vault first.
