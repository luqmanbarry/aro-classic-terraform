# Compliance Operator

Installs the Compliance Operator and the related scan settings used by this factory.

Safe defaults:

- operator install plan approval is `Automatic` because `compliance-content` depends on these CRDs
- automatic remediation stays off
- debug stays off
- the chart ships with STIG-oriented profiles, but you still need to review what is appropriate for each cluster

Enable this chart only after the platform and security teams approve the scan schedule, profiles, and remediation approach.
