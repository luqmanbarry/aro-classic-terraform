# Advanced Cluster Security Operator Bootstrap

Installs the Advanced Cluster Security operator lifecycle resources.

Safe defaults:

- operator install plan approval is `Manual`
- this chart installs only the operator pieces
- stack-specific ACS central or secured-cluster resources are not created here

Enable this chart only after the security team has approved the operator channel, sizing, and downstream ACS design.
