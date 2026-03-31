# Red Hat Insights

This chart creates the `RedHatInsights` custom resource that connects the cluster to Insights.

The chart is optional and disabled by default.

Safe defaults:

- the chart is off by default
- it fails fast if you enable it without a real credentials secret name

## How To Enable

1. Make sure the Insights operator is already available in the cluster.
2. Store the required credentials in Azure Key Vault and sync them with ESO.
3. Update `clusters/<group-path>/<cluster>/values/redhat-insights.yaml`.
4. Enable the app in `gitops.yaml`.

## Main Inputs

- `namespace`: namespace where the Insights custom resource runs.
- `insights.credentialsSecret`: name of the ESO-managed Secret with the required credentials.

## Prerequisites

- Red Hat Insights entitlement for the cluster.
- An ESO-managed Secret with the credentials expected by the operator.
