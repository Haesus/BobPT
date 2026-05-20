#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys


def run(command):
    return subprocess.run(command, check=True, capture_output=True, text=True)


def load_labels(path):
    with open(path, "r", encoding="utf-8") as file:
        labels = json.load(file)

    if not isinstance(labels, list):
        raise ValueError("labels file must contain a list.")

    for label in labels:
        for key in ("name", "color", "description"):
            if key not in label:
                raise ValueError(f"label is missing '{key}': {label}")

    return labels


def existing_labels():
    result = run(["gh", "label", "list", "--limit", "500", "--json", "name,color,description"])
    labels = json.loads(result.stdout)
    return {label["name"]: label for label in labels}


def sync_label(label, existing, dry_run):
    name = label["name"]
    color = label["color"]
    description = label["description"]

    current = existing.get(name)
    if current is None:
        command = ["gh", "label", "create", name, "--color", color, "--description", description]
        action = "create"
    elif current.get("color") != color or current.get("description") != description:
        command = ["gh", "label", "edit", name, "--color", color, "--description", description]
        action = "update"
    else:
        print(f"skip: {name}")
        return

    if dry_run:
        print(f"{action}: {name}")
        return

    run(command)
    print(f"{action}: {name}")


def prune_labels(labels, existing, dry_run):
    managed_names = {label["name"] for label in labels}

    for name in sorted(existing):
        if name in managed_names:
            continue

        if dry_run:
            print(f"delete: {name}")
            continue

        run(["gh", "label", "delete", name, "--yes"])
        print(f"delete: {name}")


def main():
    parser = argparse.ArgumentParser(description="Sync GitHub labels from a JSON label file.")
    parser.add_argument("labels_file")
    parser.add_argument("--prune", action="store_true", help="Delete labels that are not in the labels file.")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    labels = load_labels(args.labels_file)
    existing = existing_labels()

    for label in labels:
        sync_label(label, existing, args.dry_run)

    if args.prune:
        prune_labels(labels, existing, args.dry_run)

    return 0


if __name__ == "__main__":
    sys.exit(main())
