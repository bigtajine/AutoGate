#!/usr/bin/env python3
"""Scan an X-Plane install for duplicate AutoGate plugins."""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List


def find_autogate_plugin_dirs(root: Path) -> List[Path]:
    """Find folders named AutoGate under any plugins folder."""
    matches = []
    for plugins_dir in root.rglob("plugins"):
        if not plugins_dir.is_dir():
            continue
        for child in plugins_dir.iterdir():
            if child.is_dir() and child.name.lower() == "autogate":
                matches.append(child)
    return sorted(set(matches))


def find_autogate_in_custom_scenery(root: Path) -> List[Path]:
    """Find AutoGate folders only in Custom Scenery/<scenery>/plugins/."""
    cs_root = root / "Custom Scenery"
    if not cs_root.is_dir():
        return []

    matches: List[Path] = []
    for scenery in cs_root.iterdir():
        if not scenery.is_dir():
            continue
        plugins = scenery / "plugins"
        if not plugins.is_dir():
            continue
        for child in plugins.iterdir():
            if child.is_dir() and child.name.lower() == "autogate":
                matches.append(child)
    return sorted(set(matches))


def find_plugin_binaries(autogate_dir: Path) -> List[Path]:
    """Find all plugin binary files inside an AutoGate folder."""
    binaries = []
    for path in autogate_dir.rglob("*"):
        if path.is_file() and path.suffix.lower() == ".xpl":
            binaries.append(path)
    return sorted(binaries)


def target_binary_name(platform_name: str) -> str:
    """Map a platform string to the expected X-Plane plugin binary name."""
    name = platform_name.lower()
    if name.startswith("win"):
        return "win.xpl"
    if name.startswith("darwin") or name.startswith("mac"):
        return "mac.xpl"
    return "lin.xpl"


def format_paths(paths: Iterable[Path], base: Path) -> List[str]:
    out = []
    for p in paths:
        try:
            out.append(str(p.relative_to(base)))
        except ValueError:
            out.append(str(p))
    return out


def q(path: Path) -> str:
    """Return a double-quoted path string."""
    return f"\"{path}\""


@dataclass(frozen=True)
class FolderReport:
    folder: Path
    binaries: List[Path]
    active_binaries: List[Path]


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Find duplicate AutoGate plugin installs in X-Plane."
    )
    parser.add_argument(
        "xplane_root",
        nargs="?",
        default=".",
        help="Path to X-Plane root (default: current directory).",
    )
    parser.add_argument(
        "--platform",
        default=sys.platform,
        help="Platform to validate duplicates for (default: current platform).",
    )
    parser.add_argument(
        "--custom-scenery-only",
        action="store_true",
        help="Scan only Custom Scenery/<scenery>/plugins/AutoGate folders.",
    )
    args = parser.parse_args()

    root = Path(args.xplane_root).expanduser().resolve()
    if not root.exists() or not root.is_dir():
        print(f"ERROR: '{root}' is not a valid directory.")
        return 2

    active_name = target_binary_name(args.platform)
    autogate_dirs = (
        find_autogate_in_custom_scenery(root)
        if args.custom_scenery_only
        else find_autogate_plugin_dirs(root)
    )
    if not autogate_dirs:
        print("No AutoGate plugin folders found.")
        return 1

    all_bins: List[Path] = []
    active_bins: List[Path] = []
    reports: List[FolderReport] = []
    print("AutoGate plugin folders found:")
    for folder in autogate_dirs:
        bins = find_plugin_binaries(folder)
        active = [b for b in bins if b.name.lower() == active_name]
        all_bins.extend(bins)
        active_bins.extend(active)
        reports.append(FolderReport(folder=folder, binaries=bins, active_binaries=active))

    for report in reports:
        print(f"  - {q(report.folder)}")
        if report.binaries:
            for b in format_paths(report.binaries, root):
                print(f"      bin: \"{b}\"")
        else:
            print("      bin: (none)")

    installs_with_active_binary: Dict[Path, List[Path]] = {
        report.folder: report.active_binaries
        for report in reports
        if report.active_binaries
    }
    active_install_count = len(installs_with_active_binary)

    print()
    print(f"Folders: {len(autogate_dirs)}")
    print(f"All binaries (.xpl): {len(all_bins)}")
    print(f"Active binaries ({active_name}): {len(active_bins)}")
    print(f"Active installs ({active_name}): {active_install_count}")

    if active_install_count > 1:
        print("WARNING: Multiple active AutoGate installs found. Keep only one active copy.")
        print("Conflicting install folders:")
        for folder in sorted(installs_with_active_binary):
            print(f"  - {q(folder)}")
        return 3

    if active_install_count == 1:
        print("OK: Only one active AutoGate binary detected.")
        return 0

    if args.custom_scenery_only:
        print(
            f"OK: No active '{active_name}' binaries in Custom Scenery plugins "
            "(library/object-only AutoGate folders)."
        )
        return 0

    print(f"WARNING: No active '{active_name}' AutoGate binary found.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
