# Updating and Maintenance

Primary handbook sources:

- `/usr/local/share/doc/freebsd/en/books/porters-handbook/upgrading/index.html`
- `/usr/local/share/doc/freebsd/en/books/porters-handbook/keeping-up/index.html`

## Use this reference when

- upgrading an existing port
- preparing a patch or reviewable diff
- checking whether maintainer coordination is needed
- deciding whether `UPDATING` or `MOVED` must change
- following ongoing upstream and ports-tree changes

## Upgrade workflow

- confirm the port has not already been updated
- check whether there is an existing PR
- check `make maintainer` and avoid duplicating work when a maintainer is already handling the update
- refresh checksums with `make makesum`
- validate with the normal test sequence and then with `poudriere`

## Patch preparation

Prefer clean git-based diffs:

- `git diff`
- `git format-patch`

Before generating the patch:

- clean work directories
- review staged changes
- make sure file adds, removals, or renames are obvious

If files were added, moved, or removed, call that out explicitly so the committer or reviewer knows what repository operations are needed.

## Tree-wide files

Consider whether the change requires:

- `/usr/ports/UPDATING`
- `/usr/ports/MOVED`

Use `UPDATING` when users need migration or post-upgrade instructions.
Use `MOVED` when a port is renamed, relocated, or removed.

## Maintenance signals

For ongoing porter work, track:

- FreshPorts
- FreeBSD ports mailing list
- FreeBSD ports announce
- Portscout
- build-cluster fallout

When the handbook points to the source repository or `bsd.port.mk` as the definitive answer, inspect those directly.
