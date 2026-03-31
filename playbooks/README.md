# Playbooks

This directory contains Ansible Automation Platform examples for running the factory from automation.

- `aap/run_cluster_stack.yml`: run validate, plan, or apply for one cluster by calling the shared factory runner script.
- `aap/README.md`: AAP-specific inputs, prerequisites, and example usage.

Use `docs/operations/aap-execution.example.yml` as the starting point for AAP extra vars. The same grouped cluster layout works here too, for example `clusters/us-east-1/qa/aroclassic210`.
