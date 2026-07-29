#!/usr/bin/env python3
"""Local plan9port manual and environment helper."""

from __future__ import annotations

import argparse
import os
import pathlib
import shutil
import subprocess
import sys
from collections import defaultdict


def plan9_root() -> pathlib.Path:
    root = pathlib.Path(os.environ.get("PLAN9", "/opt/plan9port")).expanduser()
    return root


def man_root(root: pathlib.Path) -> pathlib.Path:
    return root / "man"


def env_for(root: pathlib.Path) -> dict[str, str]:
    env = os.environ.copy()
    env["PLAN9"] = str(root)
    env["PATH"] = f"{root / 'bin'}:{env.get('PATH', '')}"
    return env


def read_index(root: pathlib.Path) -> dict[str, list[tuple[str, str, pathlib.Path]]]:
    entries: dict[str, list[tuple[str, str, pathlib.Path]]] = defaultdict(list)
    for index in sorted(man_root(root).glob("man*/INDEX")):
        section = index.parent.name.removeprefix("man")
        for line in index.read_text(errors="replace").splitlines():
            parts = line.split()
            if len(parts) >= 2:
                name, page = parts[0], parts[1]
                entries[name].append((section, page, index.parent / page))
    return entries


def cmd_env(args: argparse.Namespace) -> int:
    root = plan9_root()
    p9bin = root / "bin"
    print(f"PLAN9={root}")
    print(f"PLAN9 exists={root.is_dir()}")
    print(f"man exists={man_root(root).is_dir()}")
    print(f"bin exists={p9bin.is_dir()}")
    print(f"shell={os.environ.get('SHELL', '')}")
    print(f"path_has_plan9_bin={str(p9bin) in os.environ.get('PATH', '').split(os.pathsep)}")
    print(f"path_first={os.environ.get('PATH', '').split(os.pathsep)[0] if os.environ.get('PATH') else ''}")
    for name in ["9", "rc", "man", "acme", "plumber", "9term", "fontsrv", "factotum", "9p", "9pfuse"]:
        found = shutil.which(name, path=f"{p9bin}:{os.environ.get('PATH', '')}")
        print(f"{name}={found or ''}")
    return 0


def cmd_search(args: argparse.Namespace) -> int:
    root = plan9_root()
    entries = read_index(root)
    terms = [term.lower() for term in args.terms]
    for name in sorted(entries):
        haystack = " ".join([name, *[page for _, page, _ in entries[name]]]).lower()
        if all(term in haystack for term in terms):
            refs = ", ".join(f"{page} section {section}" for section, page, _ in entries[name])
            print(f"{name}: {refs}")
    return 0


def cmd_man(args: argparse.Namespace) -> int:
    root = plan9_root()
    man = root / "bin" / "man"
    if not man.exists():
        print(f"missing {man}", file=sys.stderr)
        return 1
    cmd = [str(man)]
    if len(args.page) == 1:
        section = None
        name = args.page[0]
    elif len(args.page) == 2:
        section, name = args.page
    else:
        print("usage: p9doc.py man [section] name", file=sys.stderr)
        return 2
    if section:
        cmd.append(section)
    cmd.extend(["--", name])
    proc = subprocess.run(cmd, env=env_for(root), text=True)
    return proc.returncode


def cmd_path(args: argparse.Namespace) -> int:
    root = plan9_root()
    entries = read_index(root)
    for section, page, path in entries.get(args.name, []):
        if args.section and args.section != section:
            continue
        print(path)
    return 0


def cmd_audit(args: argparse.Namespace) -> int:
    root = plan9_root()
    p9bin = root / "bin"
    issues: list[str] = []
    if not root.is_dir():
        issues.append(f"$PLAN9 directory is missing: {root}")
    if not man_root(root).is_dir():
        issues.append(f"$PLAN9/man is missing: {man_root(root)}")
    if not p9bin.is_dir():
        issues.append(f"$PLAN9/bin is missing: {p9bin}")
    path_parts = os.environ.get("PATH", "").split(os.pathsep)
    if str(p9bin) == (path_parts[0] if path_parts else ""):
        issues.append("$PLAN9/bin is first in PATH; check 9(1) before making that permanent.")
    for name in ["9", "rc", "man", "acme", "plumber"]:
        if not (p9bin / name).exists():
            issues.append(f"expected plan9port binary missing: {p9bin / name}")
    if issues:
        print("Issues:")
        for issue in issues:
            print(f"- {issue}")
    else:
        print("No basic plan9port layout issues found.")
    print("Read 9(1) before changing PATH strategy.")
    return 0


def cmd_index(args: argparse.Namespace) -> int:
    root = plan9_root()
    by_section: dict[str, list[str]] = defaultdict(list)
    for name, refs in read_index(root).items():
        for section, page, _ in refs:
            by_section[section].append(f"- `{name}` -> `{page}`")
    print(f"# plan9port Manual Index\n\nGenerated from `{man_root(root)}`.\n")
    for section in sorted(by_section):
        print(f"## Section {section}\n")
        for line in sorted(set(by_section[section])):
            print(line)
        print()
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("env", help="print plan9port environment facts")
    p.set_defaults(func=cmd_env)

    p = sub.add_parser("search", help="search manual index entries")
    p.add_argument("terms", nargs="+")
    p.set_defaults(func=cmd_search)

    p = sub.add_parser("man", help="render a local manual page")
    p.add_argument("page", nargs="+")
    p.set_defaults(func=cmd_man)

    p = sub.add_parser("path", help="print local manual source path")
    p.add_argument("name")
    p.add_argument("section", nargs="?")
    p.set_defaults(func=cmd_path)

    p = sub.add_parser("audit", help="basic non-invasive environment audit")
    p.set_defaults(func=cmd_audit)

    p = sub.add_parser("index", help="emit markdown manual index")
    p.set_defaults(func=cmd_index)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
