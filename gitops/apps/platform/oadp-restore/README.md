# OADP Restore

Creates restore resources for approved backup names.

Safe defaults:

- restore creation is off by default
- no backup names or storage-class mappings are preloaded
- the chart fails fast if you enable it without a real cluster name and at least one backup name

Use this chart only for planned recovery work. Keep it disabled during normal operations.
