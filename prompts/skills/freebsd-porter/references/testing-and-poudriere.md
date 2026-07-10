# Testing and Poudriere

Primary handbook source:

- `/usr/local/share/doc/freebsd/en/books/porters-handbook/testing/index.html`

## Use this reference when

- validating a port change
- deciding what tests to run
- choosing between host-side checks and poudriere
- debugging install, plist, or dependency problems

## Baseline checks

- `make describe` must work without exploding under arbitrary `make.conf` state.
- `make test` should be run when the software supports tests.
- `portlint -A` is the stricter new-port check.
- `portlint -C` is the usual existing-port check.
- `portfmt` and `portclippy` help with Makefile order and style.

## Prefix and install discipline

- Respect `PREFIX`.
- Do not hard-code `/usr/local` in installed paths.
- `DESTDIR` support is handled by the framework; do not fight it.
- A useful smoke test is packaging with an alternate `PREFIX` to catch hard-coded install paths.

## Why poudriere is the default

The handbook treats `poudriere` as a core contributor tool because it provides:

- clean jail-based builds
- package generation
- per-port logs
- plist validation
- dependency validation
- option and version-matrix testing

Prefer `poudriere testport` over "it worked on the host" reasoning.

## Practical defaults

- fast validation:
  - `poudriere testport -j <jail> -p <tree> -o <category/port>`
- investigate failures interactively:
  - `poudriere testport -j <jail> -p <tree> -i -o <category/port>`
  - `poudriere testport -j <jail> -p <tree> -I -o <category/port>`
- test non-default options:
  - `poudriere testport -j <jail> -p <tree> -c -o <category/port>`

When an issue may depend on framework-selected versions, jump to `flavors-and-versions.md` and `poudriere-workflow.md`.
