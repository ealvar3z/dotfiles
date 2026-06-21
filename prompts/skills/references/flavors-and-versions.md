# Flavors and Versions

Primary handbook sources:

- `/usr/local/share/doc/freebsd/en/books/porters-handbook/flavors/index.html`
- `/usr/local/share/doc/freebsd/en/books/porters-handbook/testing/index.html`

## Use this reference when

- adding or fixing `FLAVORS`
- working on Python, PHP, Lua, or Guile variant handling
- testing non-default interpreter or dependency versions
- choosing between host changes and poudriere sets

## Flavor rules

- Declare `FLAVORS` in the `Makefile`.
- The first entry in `FLAVORS` is the default flavor.
- A common guard is:
  - `FLAVOR?= ${FLAVORS:[1]}`
- Flavor names must use lowercase letters, digits, and underscore.
- Each flavor must produce a distinct package name, usually via `*_PKGNAMESUFFIX` or related helpers.

## Helpers

Use framework helpers before writing custom conditionals. Common helper families include:

- `*_PKGNAMEPREFIX`
- `*_PKGNAMESUFFIX`
- `*_PLIST`
- `*_DESCR`
- `*_BUILD_DEPENDS`
- `*_RUN_DEPENDS`
- `*_LIB_DEPENDS`

## Language-specific rules

- PHP flavored dependencies should use `@${PHP_FLAVOR}`, not raw `FLAVOR`.
- Python flavored dependencies should use `PY_FLAVOR`, not raw `FLAVOR`.
- Lua flavored dependencies should use `LUA_FLAVOR`.
- Guile flavored dependencies should use `GUILE_FLAVOR`.

When `USES=php`, `USES=python`, `USES=lua`, or `USES=guile` already provide flavor machinery, follow that framework instead of layering a second custom design over it.

## Validation strategy

When flavor behavior or default-version resolution matters:

- validate with `poudriere testport`
- use `-z <set>` plus set-specific `make.conf`
- inject version overrides with lines like:
  - `DEFAULT_VERSIONS+= perl=5.20`

Do not treat a single host-side build as sufficient proof that a flavored or versioned port is correct.
