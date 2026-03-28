# Catalog

The catalog stores shared default settings for cluster stacks.

## Layout

- `cluster-classes/`: reusable default settings such as environment, version, network policy, and bootstrap flags

Terraform does not use these files by themselves.
The scripts merge them with each cluster's `cluster.yaml` file to build the final config.
