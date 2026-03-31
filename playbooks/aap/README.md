# AAP Example

This example shows how to run one cluster stack from Ansible Automation Platform.

The playbook uses the shared script `scripts/run_cluster_stack.sh`, so the AAP path follows the same steps as bastion, GitHub Actions, and Azure Pipelines.

## Inputs

- `cluster_dir`: cluster folder such as `clusters/us-east-1/qa/aroclassic210`
- `artifact_dir`: folder where rendered config, plan, and outputs are written
- `workflow_mode`: one of `validate`, `plan`, or `apply`
- `terraform_backend`: `true` or `false`
- `skip_tool_check`: skip the shared tool check only when the execution image is already controlled and validated
- `skip_az_login`: skip Azure CLI login only when the job already has a valid Azure session

## Example

```bash
ansible-playbook playbooks/aap/run_cluster_stack.yml \
  -e @docs/operations/aap-execution.example.yml \
  -e cluster_dir=clusters/us-east-1/qa/aroclassic210 \
  -e artifact_dir=/tmp/aroclassic210 \
  -e workflow_mode=plan \
  -e terraform_backend=false \
  -e skip_tool_check=false \
  -e skip_az_login=false
```

## Prerequisites

- the execution environment must have `bash`, `git`, `jq`, `python3`, `terraform`, `helm`, `rg`, `oc`, and `az`
- Azure credentials must be available to the job
- if you use backend state, the backend credentials must also be available
- the cluster directory must follow `clusters/<group-path>/<cluster>/`

## Extra Vars File

Use [docs/operations/aap-execution.example.yml](/Users/luqman/workspace/guides/aro-classic-terraform/docs/operations/aap-execution.example.yml) as the base file for AAP job template extra vars.
