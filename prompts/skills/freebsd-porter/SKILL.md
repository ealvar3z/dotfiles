---
name: freebsd-porter
description: "Create, update, debug, and prepare FreeBSD ports using the local Porter's Handbook as the primary source of truth. Use when asked to make a new port, upgrade an existing port, fix a broken port, run poudriere, validate FLAVORS or DEFAULT_VERSIONS behavior, or prepare a patch for the FreeBSD ports tree. Prefer poudriere for real validation and use the handbook sections under /usr/local/share/doc/freebsd/en/books/porters-handbook/. Triggers on: freebsd porter, freebsd port, ports tree, poudriere, make makesum, portlint, flavorized port, py_flavor, php_flavor, upgrading a port."
---

# FreeBSD Porter

Use this skill for FreeBSD Ports Collection work. Treat the locally installed Porter's Handbook as the primary reference before relying on memory.

## Source of truth

Read these local handbook pages first when relevant:

- `/usr/local/share/doc/freebsd/en/books/porters-handbook/quick-porting/index.html`
- `/usr/local/share/doc/freebsd/en/books/porters-handbook/testing/index.html`
- `/usr/local/share/doc/freebsd/en/books/porters-handbook/flavors/index.html`
- `/usr/local/share/doc/freebsd/en/books/porters-handbook/upgrading/index.html`
- `/usr/local/share/doc/freebsd/en/books/porters-handbook/keeping-up/index.html`

When the handbook is still not detailed enough, inspect:

- `/usr/ports/Mk/bsd.port.mk`
- related `Mk/Uses/*.mk` files
- the target port's existing files

## Default contract

- Prefer `poudriere` for meaningful validation.
- Do not trust host-installed libraries or tools as proof that a port is correct.
- Keep changes aligned with ports framework conventions instead of inventing custom logic.
- Use `make makesum`; do not hand-edit `distinfo`.
- Use `portlint`, `portfmt`, and `portclippy` as helpers, not as unquestionable authority.
- For upgrades and submissions, produce clean diffs and account for added, removed, or moved files.

## Workflow

1. Inspect the target port or proposed new port and identify whether the task is new-port work, upgrade work, QA/debugging, flavor work, or submission prep.
2. Load the matching reference file from `references/`.
3. Confirm the correct ports-framework shape before editing:
   - required files
   - `USES` and framework helpers
   - `FLAVORS`, `*_FLAVOR`, or `DEFAULT_VERSIONS` implications
4. Apply or propose the port changes.
5. Run the handbook test sequence where practical:
   - `make stage`
   - `make stage-qa`
   - `make package`
   - `make install`
   - `make deinstall`
   - `make package` as an unprivileged user
6. Prefer `poudriere testport` for isolated validation. Use `-c`, `-i`, `-I`, or `-z` sets when the problem requires options, debugging, or version matrix checks.
7. For upgrades or submissions, prepare a clean `git diff` or `git format-patch` style patch and note file adds, removes, or renames when relevant.
8. For ongoing maintenance, check whether `UPDATING`, `MOVED`, maintainer contact, FreshPorts, or Portscout considerations apply.

## Which reference to load

- New port or quick skeleton work:
  - `references/new-port.md`
- General QA, test order, or poudriere choice:
  - `references/testing-and-poudriere.md`
- Detailed poudriere setup or usage:
  - `references/poudriere-workflow.md`
- Flavors, language-version variants, or `DEFAULT_VERSIONS`:
  - `references/flavors-and-versions.md`
- Existing-port upgrades, patch prep, or maintainer workflow:
  - `references/updating-and-maintenance.md`

## Poudriere defaults

Use `poudriere` as the default validation path when available.

- Single port:
  - `poudriere testport -j <jail> -p <tree> -o <category/port>`
- With options dialog:
  - `poudriere testport -j <jail> -p <tree> -c -o <category/port>`
- Leave the jail for interactive investigation:
  - `poudriere testport -j <jail> -p <tree> -I -o <category/port>`
- Version or option matrix via set:
  - `poudriere testport -j <jail> -p <tree> -z <set> -o <category/port>`

When a task involves `DEFAULT_VERSIONS`, flavors, or non-default dependency stacks, prefer sets and custom `make.conf` files instead of ad hoc host changes.
