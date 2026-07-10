# Poudriere Workflow

Primary handbook source:

- `/usr/local/share/doc/freebsd/en/books/porters-handbook/testing/index.html`

Focus on section `10.7. poudriere`.

## Use this reference when

- setting up poudriere
- creating or updating jails
- configuring a ports tree for builds
- testing with sets or custom `make.conf`
- debugging a build inside a jail

## Core setup model

The handbook's default layout assumes:

- config: `/usr/local/etc/poudriere.conf`
- local overrides: `/usr/local/etc/poudriere.d/`
- ports tree rooted at `/usr/ports` by default
- jail builds in a clean ZFS-backed environment

Important config concepts:

- `ZPOOL`
- `BASEFS`
- `DISTFILES_CACHE`
- `RESOLV_CONF`

## Common actions

- install:
  - `pkg install poudriere`
- create a release jail:
  - `poudriere jail -c -j 143Ramd64 -v 14.3-RELEASE -a amd64`
- list jails:
  - `poudriere jail -l`
- update a jail:
  - `poudriere jail -u -j <jail>`
- create a ports tree:
  - `poudriere ports -c -p <tree> -m git+https`

## Test flow

- single port:
  - `poudriere testport -j <jail> -p <tree> -o <category/port>`
- prompt for options:
  - `... -c ...`
- drop into a shell after the build:
  - `... -i ...`
- leave the jail running for manual testing:
  - `... -I ...`

## Sets and custom make.conf

Use sets when the problem depends on options or framework-selected defaults.

- set selection:
  - `-z <setname>`
- custom options trees live under:
  - `/usr/local/etc/poudriere.d/*-options`
- custom make files live under:
  - `/usr/local/etc/poudriere.d/*-make.conf`

The handbook notes that all matching `make.conf` files are appended in order, which is the safe way to inject version overrides like:

- `DEFAULT_VERSIONS+= perl=5.20`

Use this mechanism for version-matrix testing instead of changing the host globally.

## Distfiles maintenance

Prune obsolete distfiles with:

- `poudriere distclean -p <tree>`
- `poudriere distclean -p <tree> -y`
