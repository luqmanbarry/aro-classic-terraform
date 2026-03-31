# Global Pull Secret

Updates the cluster-wide pull secret with extra registry credentials from Azure Key Vault.

Safe defaults:

- the chart fails fast if the Key Vault store or secret name is still a placeholder
- it reads credentials through External Secrets Operator instead of storing them in Git

The pull secret must be of this json object format:

```yaml
{
  "auths": {
    "my-registry.example.com": {
      "username": "value",
      "password": "value"
    }
  }
}
```

Once you have the pull secret, create a KeyVault secret with value the json object.

Update the cluster values file to set the Key Vault secret name before you enable the app.
