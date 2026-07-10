# New Port

Primary handbook sources:

- `/usr/local/share/doc/freebsd/en/books/porters-handbook/new-port/index.html`
- `/usr/local/share/doc/freebsd/en/books/porters-handbook/quick-porting/index.html`

## Use this reference when

- creating a new port
- checking the minimum required file set
- deciding whether quick-porting guidance is enough

## Required shape

At minimum, expect:

- `Makefile`
- `distinfo`
- `pkg-descr`
- usually `pkg-plist`, unless `PLIST_FILES` is clearly justified and small

Use the framework shape from the handbook rather than inventing custom targets or variables.

## Key rules

- Start from the smallest correct `Makefile`.
- Prefer framework helpers in `USES` and related knobs before writing custom logic.
- Keep `pkg-descr` meaningfully longer than `COMMENT`.
- Use `make makesum` to generate `distinfo`.
- Do not manually compose checksum entries.
- Ensure the port only uses the network during `fetch`.
- Ensure `make package` works as a normal user where the framework expects it to.

## Recommended local validation order

The handbook's quick-porting test order is:

1. `make stage`
2. `make stage-qa`
3. `make package`
4. `make install`
5. `make deinstall`
6. `make package` as a normal user

Then run isolated validation with `poudriere testport`.

## Submission baseline

Before submission:

- read the DOs and DON'Ts section if the task reaches that point
- remove build artifacts
- prepare a clean diff
- do not submit shar archives
