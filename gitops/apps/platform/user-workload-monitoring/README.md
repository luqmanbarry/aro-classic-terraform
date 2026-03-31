# User Workload Monitoring

Configures the `cluster-monitoring-config` ConfigMap for user workload monitoring.

Safe defaults:

- user workload monitoring is off by default
- storage settings must be reviewed before you enable it in production

Set values in `clusters/<group-path>/<cluster>/values/user-workload-monitoring.yaml` before you enable the app.
