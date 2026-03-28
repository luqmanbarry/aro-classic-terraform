# Clusters

Each directory under `clusters/` represents one ARO classic cluster in one environment.

Most users will work in this folder. They update cluster files here and open a pull request. CI checks the files, creates the final generated config, and saves artifacts.

## Layout

```text
clusters/
  dev/
    aroclassic101/
      cluster.yaml
      gitops.yaml
      values/
        external-secrets-operator.yaml
      main.tf
      variables.tf
      versions.tf
      outputs.tf
```

## Files

- `cluster.yaml`: main cluster settings such as Azure region, networking, sizing, Key Vault, and bootstrap flags
- `gitops.yaml`: list of GitOps apps for this cluster, including what is enabled and which values files to use
- `values/*.yaml`: one values file per GitOps app
- Terraform wrapper files: small root module files that call `modules/factory-stack`

Put shared defaults in `catalog/cluster-classes/`.
Put cluster-specific values in `clusters/<environment>/<cluster>/`.

For runner-specific execution steps, approval patterns, and command sequences, see [Execution Models](../docs/operations/execution-models.md).
