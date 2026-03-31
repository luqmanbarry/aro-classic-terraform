#!/usr/bin/env python3

import argparse
from pathlib import Path
import sys

import yaml


def load_yaml(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        return yaml.safe_load(handle) or {}


def fail(message: str):
    print(f"validation failed: {message}", file=sys.stderr)
    raise SystemExit(1)


def validate_cluster_directory(cluster_dir: Path, repo_root: Path):
    clusters_root = repo_root / "clusters"
    if not cluster_dir.is_relative_to(clusters_root):
        fail(f"{cluster_dir} must live under {clusters_root}/")

    relative_parts = cluster_dir.relative_to(clusters_root).parts
    if len(relative_parts) < 2:
        fail(
            f"{cluster_dir} must use the layout clusters/<group-path>/<cluster-name>/; "
            "group-path can be one or more levels such as env, region/env, bu/env, or failure-domain/env"
        )

    return relative_parts


def validate_cluster(cluster_file: Path, cluster: dict):
    required = ["cluster_name", "class_name", "business_metadata", "network", "key_vault", "gitops"]
    missing = [key for key in required if key not in cluster]
    if missing:
        fail(f"{cluster_file} is missing required cluster keys: {', '.join(missing)}")


def validate_gitops(repo_root: Path, stack_root: Path, gitops):
    applications = gitops.get("applications", [])
    if not isinstance(applications, list):
        fail("gitops applications must be a list")

    for app in applications:
        if "enabled" not in app or "name" not in app:
            fail("each gitops application requires at least name and enabled")

        if "path" in app:
            chart_path = repo_root / app["path"] / "Chart.yaml"
            if not chart_path.exists():
                fail(f"missing Chart.yaml for app path: {chart_path}")
        elif not all(key in app for key in ["chart", "repoURL", "targetRevision"]):
            fail(f"gitops app {app['name']} must define either path or chart/repoURL/targetRevision")

        for value_file in app.get("valueFiles", []):
            value_file_path = repo_root / value_file
            if not value_file_path.exists():
                fail(f"missing values file: {value_file_path}")
            if stack_root not in value_file_path.parents and (repo_root / "clusters") not in value_file_path.parents:
                fail(f"values file is outside allowed cluster paths: {value_file}")
            load_yaml(value_file_path)


def main():
    parser = argparse.ArgumentParser(description="Validate factory stack inputs.")
    parser.add_argument("--cluster-dir", help="Path to one cluster directory")
    parser.add_argument("--cluster", help="Path to cluster.yaml")
    parser.add_argument("--gitops-values", help="Path to gitops.yaml")
    args = parser.parse_args()

    repo_root = Path.cwd().resolve()
    if args.cluster_dir:
        stack_root = Path(args.cluster_dir).resolve()
        cluster_path = stack_root / "cluster.yaml"
        gitops_path = stack_root / "gitops.yaml"
    else:
        if not args.cluster or not args.gitops_values:
            fail("use --cluster-dir or provide both --cluster and --gitops-values")
        cluster_path = Path(args.cluster).resolve()
        gitops_path = Path(args.gitops_values).resolve()
        stack_root = cluster_path.parent

    relative_parts = validate_cluster_directory(stack_root, repo_root)
    for required_file in [cluster_path, gitops_path, stack_root / "main.tf"]:
        if not required_file.exists():
            fail(f"required file missing: {required_file}")

    cluster = load_yaml(cluster_path)
    validate_cluster(cluster_path, cluster)
    if cluster.get("cluster_name") != relative_parts[-1]:
        fail(
            f"{cluster_path} cluster_name '{cluster.get('cluster_name')}' must match the cluster directory name "
            f"'{relative_parts[-1]}'"
        )
    validate_gitops(repo_root, stack_root, load_yaml(gitops_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
