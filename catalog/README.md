# Catalog

The catalog stores shared default settings for cluster stacks.

## Layout

- `cluster-classes/`: reusable default settings such as environment, version, network policy, and bootstrap flags
- `machine-pool-classes/`: reusable example defaults for extra ARO machine pools

## Cluster Class Examples

- `dev.yaml`
- `qa.yaml`
- `prod.yaml`
- `prod-dr.yaml`

## Machine-Pool Class Examples

- `system.yaml`
- `observability.yaml`
- `aap.yaml`
- `ai.yaml`

Terraform does not use these files by themselves.
The scripts merge them with each cluster's `cluster.yaml` file to build the final config.

Keep path grouping decisions in `clusters/`. Keep real environment metadata in YAML so automation does not depend on the folder name.
