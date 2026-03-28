# GitOps Readiness

This document tracks whether each current GitOps app in this repository is ready to deploy on ARO classic when enabled.

Readiness here means:

- the chart exists with Kubernetes manifests
- the chart renders successfully with its current contract
- secret-consuming apps own their own `ExternalSecret` resources when they fetch secrets from an external backend

## Ready Platform Apps

- `advanced-cluster-security-operator-bootstrap`
- `cert-manager-config`
- `cert-manager-operator`
- `cluster-logging`
- `compliance-content`
- `compliance-operator`
- `external-secrets-config`
- `external-secrets-operator`
- `file-integrity-operator-bootstrap`
- `global-cluster-pull-secret`
- `groups-rbac`
- `identity-providers`
- `image-registry-allow-deny`
- `internal-image-registry`
- `namespace-onboarding`
- `oadp-backup`
- `oadp-operator`
- `oadp-restore`
- `openshift-data-foundation-operator-bootstrap`
- `openshift-pipelines-operator-bootstrap`
- `openshift-service-mesh-operator-bootstrap`
- `openshift-virtualization-operator-bootstrap`
- `self-provisioner`
- `splunk-log-forwarding`
- `user-workload-monitoring`
- `vault-k8s-auth`

## Ready Workload Apps

- `aap`
- `cp4ba-operator`
- `openshift-ai`

## External Chart Entry

- `twistlock-defender-helm`

This one is not an in-repo chart. It stays as an external Helm chart entry in cluster `gitops.yaml`, so readiness depends on the external chart source and the cluster values file.

## Secret Ownership

These apps define their own `ExternalSecret` resources:

- `cluster-logging`
- `global-cluster-pull-secret`
- `identity-providers`
- `image-registry-allow-deny`
- `namespace-onboarding`
- `oadp-operator`
- `openshift-service-mesh-operator-bootstrap`
- `splunk-log-forwarding`

These apps define the shared secret-store side of the contract:

- `external-secrets-config`
- `external-secrets-operator`

These apps do not currently require an external secret contract in their chart logic:

- `advanced-cluster-security-operator-bootstrap`
- `cert-manager-config`
- `cert-manager-operator`
- `compliance-content`
- `compliance-operator`
- `file-integrity-operator-bootstrap`
- `groups-rbac`
- `internal-image-registry`
- `oadp-backup`
- `oadp-restore`
- `openshift-data-foundation-operator-bootstrap`
- `openshift-pipelines-operator-bootstrap`
- `openshift-virtualization-operator-bootstrap`
- `self-provisioner`
- `user-workload-monitoring`
- `vault-k8s-auth`
- `aap`
- `cp4ba-operator`
- `openshift-ai`

## Verification

The current repository has been checked with:

- per-app `helm template` rendering for the 27 sample cluster entries
- `helm template` rendering for workload charts `aap`, `cp4ba-operator`, and `openshift-ai`
- cluster input validation
- effective-config rendering
- Terraform validation for the sample cluster stack
