# aro-classic-acm-registration

Registers an ARO classic cluster to an ACM hub after kubeconfig is created.

## Default Behavior

This module is opt-in.

It does not run unless `enable_acm_registration: true` is set in the cluster inputs.

## What It Does

When enabled, the module:

- creates the namespace for the cluster on the ACM hub
- creates the `ManagedCluster` on the hub
- creates the `KlusterletAddonConfig` on the hub
- creates the `auto-import-secret` on the hub by using the managed cluster kubeconfig

## Required Inputs

- managed cluster kubeconfig
- ACM hub cluster details secret name in Key Vault

## Notes

- The module follows the ACM auto-import-secret pattern on the hub, which is the cleaner current import flow.
- Keep it disabled by default unless the customer wants this repo to register the cluster into ACM.
