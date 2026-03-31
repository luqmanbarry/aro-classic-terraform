# Splunk Log Forwarding

Creates an `ExternalSecret` for the Splunk HEC token and an Argo CD child app that deploys the Splunk OpenTelemetry Collector chart.

Safe defaults:

- the chart fails fast if cluster name, endpoint, index, or secret-store values are still placeholders
- the Argo CD child app uses the shared `platform` project
- all secrets come from Azure Key Vault through External Secrets Operator

Before you enable this chart:

1. Put the HEC token in Azure Key Vault.
2. Set the real endpoint and index in `clusters/<group-path>/<cluster>/values/splunk-log-forwarding.yaml`.
3. Confirm the target namespace and proxy settings for your environment.
