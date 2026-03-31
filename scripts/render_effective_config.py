#!/usr/bin/env python3

import argparse
import json
from pathlib import Path
import sys

import yaml


REQUIRED_CLUSTER_KEYS = [
    "cluster_name",
    "class_name",
    "business_metadata",
    "network",
    "key_vault",
    "gitops",
]


def deep_merge(base, override):
    if isinstance(base, dict) and isinstance(override, dict):
        merged = dict(base)
        for key, value in override.items():
            if key in merged:
                merged[key] = deep_merge(merged[key], value)
            else:
                merged[key] = value
        return merged
    return override


def load_yaml(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        return yaml.safe_load(handle) or {}


def validate_cluster(cluster):
    missing = [key for key in REQUIRED_CLUSTER_KEYS if key not in cluster]
    if missing:
        raise ValueError(f"missing required cluster keys: {', '.join(missing)}")


def validate_cluster_directory(cluster_dir: Path, repo_root: Path):
    clusters_root = (repo_root / "clusters").resolve()
    if not cluster_dir.is_relative_to(clusters_root):
        raise ValueError(f"{cluster_dir} must live under {clusters_root}/")

    relative_parts = cluster_dir.relative_to(clusters_root).parts
    if len(relative_parts) < 2:
        raise ValueError(
            f"{cluster_dir} must use the layout clusters/<group-path>/<cluster-name>/; "
            "group-path can be one or more levels such as env, region/env, bu/env, or failure-domain/env"
        )

    return clusters_root, relative_parts


def main():
    parser = argparse.ArgumentParser(description="Render effective ARO classic cluster configuration.")
    parser.add_argument("--cluster-dir", help="Path to one cluster directory")
    parser.add_argument("--cluster", help="Path to cluster.yaml")
    parser.add_argument("--gitops-values", help="Path to gitops.yaml")
    parser.add_argument("--catalog-root", default="catalog/cluster-classes", help="Path to cluster class catalog")
    parser.add_argument("--output-dir", required=True, help="Directory for generated artifacts")
    args = parser.parse_args()

    catalog_root = Path(args.catalog_root)
    output_dir = Path(args.output_dir)
    repo_root = Path.cwd().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    if args.cluster_dir:
        cluster_dir = Path(args.cluster_dir).resolve()
        cluster_path = cluster_dir / "cluster.yaml"
        gitops_path = cluster_dir / "gitops.yaml"
    else:
        if not args.cluster or not args.gitops_values:
            raise ValueError("use --cluster-dir or provide both --cluster and --gitops-values")
        cluster_path = Path(args.cluster).resolve()
        gitops_path = Path(args.gitops_values).resolve()
        cluster_dir = cluster_path.parent

    cluster = load_yaml(cluster_path)
    validate_cluster(cluster)
    clusters_root, relative_parts = validate_cluster_directory(cluster_dir, repo_root)
    if cluster.get("cluster_name") != relative_parts[-1]:
        raise ValueError(
            f"cluster_name {cluster.get('cluster_name')} does not match cluster directory name {cluster_dir.name}"
        )
    group_path = "/".join(relative_parts[:-1])

    class_path = catalog_root / f"{cluster['class_name']}.yaml"
    if not class_path.exists():
        raise FileNotFoundError(f"cluster class not found: {class_path}")

    cluster_class = load_yaml(class_path)
    gitops_values = load_yaml(gitops_path)

    effective = deep_merge(cluster_class, cluster)
    effective.setdefault("gitops", {})
    effective["gitops"]["values"] = gitops_values
    effective["source"] = {
        "cluster_file": str(cluster_path),
        "class_file": str(class_path),
        "gitops_file": str(gitops_path),
        "cluster_dir": str(cluster_dir),
        "cluster_group_path": group_path,
    }

    build_metadata = {
        "cluster_name": effective["cluster_name"],
        "class_name": effective["class_name"],
        "environment": effective.get("environment"),
        "azure_region": effective.get("azure_region"),
        "openshift_version": effective.get("openshift_version"),
        "group_path": group_path,
        "cluster_dir": str(cluster_dir),
    }

    for name, payload in {
        "effective-config.json": effective,
        "terraform.auto.tfvars.json": effective,
        "build-metadata.json": build_metadata,
    }.items():
        with (output_dir / name).open("w", encoding="utf-8") as handle:
            json.dump(payload, handle, indent=2, sort_keys=True)
            handle.write("\n")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"render failed: {exc}", file=sys.stderr)
        raise
