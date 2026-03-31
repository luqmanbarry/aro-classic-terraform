# OpenShift Service Mesh Operator Bootstrap

Installs the Service Mesh, Kiali, OpenTelemetry, and Tempo operators and can create tenant mesh resources.

Safe defaults:

- all operator install plans use `Manual`
- no tenant meshes are created by default
- the chart fails fast if you enable it without approved tenant entries
- Tempo storage secrets are expected from Azure Key Vault through External Secrets Operator

This chart is high impact. Enable it only after tenant names, tracing storage, and mesh ownership are approved.
