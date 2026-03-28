# machine-pools

Use this app to manage extra ARO worker capacity after the cluster exists.

This app renders:

- `MachineSet` objects
- `MachineAutoscaler` objects

For ARO, this is the safer day-2 pattern for extra worker capacity. Keep base cluster creation in Terraform. Add extra machine sets in GitOps after the cluster is up.

How to use it:

1. Get an existing machine set from the cluster with `oc get machineset -n openshift-machine-api -o yaml`.
2. Copy one worker `MachineSet` into `clusters/<env>/<cluster>/values/machine-pools.yaml`.
3. Change the name, labels, replicas, VM size, and zone for the new pool.
4. Add a `MachineAutoscaler` entry if you want autoscaling for that machine set.
5. Enable this app in `gitops.yaml`.

Important ARO note:

- do not build a new Azure provider spec from scratch if you can avoid it
- copy a real ARO worker `MachineSet` first, then edit it
- keep the image, identity, network, and secret fields from the real cluster unless you know they need to change
