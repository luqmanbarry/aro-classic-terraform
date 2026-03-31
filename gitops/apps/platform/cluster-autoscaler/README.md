# cluster-autoscaler

Use this app to manage the OpenShift `ClusterAutoscaler` object for ARO.

This app does not create machine sets by itself. Use it together with the `machine-pools` app if you want autoscaling on extra machine pools.

How to use it:

1. Set the values in `clusters/<env>/<cluster>/values/cluster-autoscaler.yaml`.
2. Enable this app in `gitops.yaml`.
3. Add `MachineAutoscaler` objects in the `machine-pools` app for each machine set that should scale.
