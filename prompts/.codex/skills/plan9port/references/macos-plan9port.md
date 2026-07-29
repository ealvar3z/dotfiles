# macOS plan9port Environment Notes

Use these notes as a checklist, not as authority. Confirm details in `$PLAN9/man`.

## Source of Truth

- Read `9(1)` before changing shell path behavior.
- Read `acme(1)` and `acme(4)` before changing Acme startup, fonts, or external integrations.
- Read `plumber(4)` before editing plumbing rules or startup hooks.
- Read `fontsrv(4)`, `font(7)`, and `devdraw(1)` for font/display issues.
- Read `factotum(4)` for auth/key handling and `9p(1)`/`9pfuse(4)` for 9P mounting.

## Audit Targets

- `$PLAN9` should point at the installed tree, usually `/opt/plan9port` on this machine.
- `$PLAN9/bin` should be available for command-scoped use. Be cautious about making it the permanent first path component because of Unix command name collisions.
- Shell files to inspect when asked to make the environment seamless: `~/.zshrc`, `~/.zprofile`, `~/.profile`, `~/.config/zsh/*`, and project-local env files.
- macOS integration files may live under `$PLAN9/mac`, including app bundles for `9term` and `Plumb`.
- User plumbing rules and Plan 9 support files may live under `$PLAN9/plumb`, `$HOME/lib`, or environment-specific startup scripts.

## Verification Patterns

- Check local docs: `python3 scripts/p9doc.py search <term>` then `python3 scripts/p9doc.py man <section> <name>`.
- Check command visibility without mutating shell state: `PLAN9=/opt/plan9port /opt/plan9port/bin/9 <cmd>`.
- Check path collision risk by comparing `command -v <name>` with `$PLAN9/bin/<name>`.
- Check running GUI/service pieces with `ps`, `pgrep`, or `launchctl` before changing startup behavior.
