---
name: plan9port
description: Work with Plan 9 from User Space on macOS. Use when asked to configure, audit, troubleshoot, or improve a plan9port environment; integrate $PLAN9 with zsh, rc, acme, plumber, fontsrv, 9term, factotum, 9p, FUSE mounts, or macOS launch/open workflows; explain plan9port commands or libraries; or verify that OS X and plan9port behave seamlessly together. The installed $PLAN9 manuals are the source of truth.
---

# Plan9port

## Operating Rules

- Treat the local `$PLAN9` tree as authoritative. Prefer `$PLAN9/man` over memory, web results, or generic Plan 9 documentation.
- Before giving configuration advice, discover `PLAN9`, `PATH`, shell startup files, installed binaries, and relevant manual pages.
- Do not recommend putting `$PLAN9/bin` permanently before system paths unless the manuals support that exact choice for the case at hand. The `9(1)` manual warns that many Plan 9 commands intentionally differ from Unix commands.
- Preserve the user's shell and dotfile style. Patch narrowly and keep reversible changes.
- For macOS integration, verify behavior with local commands where practical: `9 man`, `9 acme`, `9 plumber`, `9 9p`, `9 9term`, `9 fontsrv`, `9 factotum`, `launchctl`, shell init files, and app bundles under `$PLAN9/mac`.

## Quick Start

Use `scripts/p9doc.py` for local manual work:

```bash
python3 /Users/eax/.codex/skills/plan9port/scripts/p9doc.py env
python3 /Users/eax/.codex/skills/plan9port/scripts/p9doc.py search acme plumber font
python3 /Users/eax/.codex/skills/plan9port/scripts/p9doc.py man 1 9
python3 /Users/eax/.codex/skills/plan9port/scripts/p9doc.py man 4 plumber
python3 /Users/eax/.codex/skills/plan9port/scripts/p9doc.py audit
```

If a question involves a specific command, read that command's manual first. If it involves integration, also read `9(1)` and any service manual involved, such as `plumber(4)`, `acme(1)`, `acme(4)`, `factotum(4)`, `fontsrv(4)`, `9pfuse(4)`, or `9p(1)`.

## Workflow

1. Run `p9doc.py env` or equivalent shell commands to confirm the active `$PLAN9`, binaries, shell, and path order.
2. Search the local manuals with `p9doc.py search <terms>` and read the relevant pages with `p9doc.py man`.
3. Inspect the user's macOS integration points only as needed: `~/.zshrc`, `~/.zprofile`, `~/.profile`, `~/.config`, LaunchAgents, `$PLAN9/mac`, `$PLAN9/plumb`, and running processes.
4. Propose or make the smallest changes that align with the manuals.
5. Verify with actual commands. Prefer checks that avoid starting GUI apps unless the user asks to launch them.

## Common Tasks

- **Shell integration**: use `9`, `9.rc`, `u`, and `u.rc` semantics from `9(1)`. Favor command-scoped `9 <cmd>` for Unix shells when path collision risk matters.
- **Acme setup**: use `acme(1)` for editor behavior and `acme(4)` for its file interface. Check fonts, plumber state, namespace mounts, and macOS app wrappers separately.
- **Plumbing**: use `plumber(4)` and local rules under `$PLAN9/plumb`. Confirm whether the plumber is running before editing rules or startup hooks.
- **Fonts and display**: use `fontsrv(4)`, `font(7)`, `devdraw(1)`, `9term(1)`, and `acme(1)` as applicable.
- **Authentication and networking**: use `factotum(4)`, `9p(1)`, `9import(4)`, `9pserve(4)`, and `9pfuse(4)` before changing keys, sockets, or mount behavior.
- **C development**: use section 3 manuals and existing `$PLAN9/include`, `$PLAN9/src`, `9c(1)`, and `9l(1)`.

## References

- `references/manual-index.md`: generated index of the installed manuals by section.
- `references/macos-plan9port.md`: focused notes for macOS and plan9port environment audits.
