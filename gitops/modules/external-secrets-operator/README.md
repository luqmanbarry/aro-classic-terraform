# External Secrets Operator

The docs are available [here](https://external-secrets.io/latest/provider/azure-key-vault/).

## Install

Installing the operator is similar to how many other OpenShift operators are installed.

## Uninstall

1. Go to the Operator > Actions > Uninstall Operator or Delete ClusterServiceVersion
2. Go to Home > Search > Resources > Select All Projects and search for these resources and delete them.
   - ClusterExternalSecrets
   - ExternalSecrets
   - ClusterSecretStores
   - SecretStores
   - CustomResourceDefinitions/OperatorConfig
   - CustomResourceDefinitions/Webhook

## Common Issues

### Operator installation stuck in Pending

This problem occurs when an previous installation of this operator was not property removed from the cluster.

To fix this, follow the **Uninstall** steps and try to install the operator again.
