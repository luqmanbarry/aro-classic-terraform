# Clusters

Each cluster gets its own folder under:

`clusters/<group-path>/<cluster-name>/`

`<group-path>` is flexible. It can be one level or many levels. It can represent:

- an environment such as `dev`, `qa`, or `prod`
- a region with environment under it such as `us-east-1/qa`
- a business unit with environment under it such as `bu-retail/prod`
- a failure domain with environment under it such as `fd1/prod-dr`
- any other approved grouping that helps your operating model

The directory path is for human organization only. Automation still trusts `cluster.yaml`.

Examples:

- `clusters/dev/aroclassic101/`
- `clusters/us-east-1/qa/aroclassic210/`
- `clusters/bu-retail/prod/aroclassic310/`
- `clusters/fd1/prod-dr/aroclassic410/`

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
  us-east-1/
    qa/
      aroclassic210/
  bu-retail/
    prod/
      aroclassic310/
  fd1/
    prod-dr/
      aroclassic410/
```

## Files

- `cluster.yaml`: main cluster settings such as Azure region, networking, sizing, Key Vault, and bootstrap flags
- `managed_identity`: choose whether the cluster is created with the default service principal path or the optional managed identity path
- `infrastructure`: choose whether this repo uses existing customer-managed Azure resources or builds them itself
- `gitops.yaml`: list of GitOps apps for this cluster, including what is enabled and which values files to use
- `values/*.yaml`: one values file per GitOps app
- Terraform wrapper files: small root module files that call `modules/factory-stack`

Put shared defaults in `catalog/cluster-classes/`.
Put cluster-specific values in `clusters/<group-path>/<cluster>/`.

Validation rules:

- the cluster folder must live under `clusters/`
- the layout must end with `<group-path>/<cluster-name>/`
- the cluster directory name must match `cluster.yaml` field `cluster_name`
- keep environment, region, business unit, and failure-domain metadata in YAML, not only in the folder name

Important rule:

- the directory path is for human organization
- the real automation inputs still live in `cluster.yaml`
- rendered files such as `terraform.auto.tfvars.json` are local outputs and should not be committed

For runner-specific execution steps, approval patterns, and command sequences, see [Execution Models](../docs/operations/execution-models.md).
