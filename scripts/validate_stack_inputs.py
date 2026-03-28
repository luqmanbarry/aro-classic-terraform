#!/usr/bin/env python3

import argparse
from pathlib import Path
import sys

import yaml


def load_yaml(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        return yaml.safe_load(handle) or {}


def validate_cluster(cluster):
    required = ["cluster_name", "class_name", "business_metadata", "network", "key_vault", "gitops"]
    missing = [key for key in required if key not in cluster]
    if missing:
        raise ValueError(f"missing required cluster keys: {', '.join(missing)}")


def validate_gitops(repo_root: Path, stack_root: Path, gitops):
    applications = gitops.get("applications", [])
    if not isinstance(applications, list):
        raise ValueError("gitops applications must be a list")

    for app in applications:
        if "enabled" not in app or "name" not in app:
            raise ValueError("each gitops application requires at least name and enabled")

        if "path" in app:
            chart_path = repo_root / app["path"] / "Chart.yaml"
            if not chart_path.exists():
                raise FileNotFoundError(f"missing Chart.yaml for app path: {chart_path}")
        elif not all(key in app for key in ["chart", "repoURL", "targetRevision"]):
            raise ValueError(f"gitops app {app['name']} must define either path or chart/repoURL/targetRevision")

        for value_file in app.get("valueFiles", []):
            value_file_path = repo_root / value_file
            if not value_file_path.exists():
                raise FileNotFoundError(f"missing values file: {value_file_path}")
            if stack_root not in value_file_path.parents and (repo_root / "clusters") not in value_file_path.parents:
                raise ValueError(f"values file is outside allowed cluster paths: {value_file}")
            load_yaml(value_file_path)


def main():
    parser = argparse.ArgumentParser(description="Validate factory stack inputs.")
    parser.add_argument("--cluster", required=True, help="Path to cluster.yaml")
    parser.add_argument("--gitops-values", required=True, help="Path to gitops.yaml")
    args = parser.parse_args()

    cluster_path = Path(args.cluster).resolve()
    gitops_path = Path(args.gitops_values).resolve()
    repo_root = Path.cwd().resolve()
    stack_root = cluster_path.parent

    validate_cluster(load_yaml(cluster_path))
    validate_gitops(repo_root, stack_root, load_yaml(gitops_path))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"validation failed: {exc}", file=sys.stderr)
        raise
