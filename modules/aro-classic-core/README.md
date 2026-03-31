# aro-classic-core

Creates the ARO classic cluster and saves runtime connection details to Key Vault.

This module also writes cluster DNS `A` records when a custom child zone is used.

It supports two cluster identity paths:

- default service principal path
- optional managed identity path for new clusters

The managed identity path is opt-in and is intended for clusters that are created from scratch with managed identities enabled.
