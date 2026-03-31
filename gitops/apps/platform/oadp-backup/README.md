# OADP Backup

Creates Velero `Schedule` resources for approved namespaces.

Safe defaults:

- backup creation is off by default
- no schedules are created until you add real project entries
- the chart fails fast if you enable it without a real cluster name or projects list

Use this chart only after `oadp-operator` is installed and working.
