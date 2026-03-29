---
name: macos-local-installer
description: Install software on macOS into the user's local prefix with minimal friction, correct architecture handling, and efficient dependency triage. Use when the user wants Brew-like or source-based installs without sudo, especially under $HOME/.local or an already-exported $PREFIX.
---

# macOS Local Installer

Install software on macOS into a user-local prefix efficiently and predictably.

## When to Use

- Use when the user wants software installed on macOS without `sudo`.
- Use when the user wants Brew-like or MacPorts-like results, but under a local prefix.
- Use when the user wants source builds, release tarballs, or user-local dependency chains.
- Use when the install target should be `"$PREFIX"` or, if unset, `$HOME/.local`.

## Default Contract

- Respect the current machine and shell environment before assuming defaults.
- If `PREFIX` is already exported, treat that as the install target.
- If `PREFIX` is not set, default to `"$HOME/.local"` and use it consistently.
- Prefer non-root installs and prefix-aware build systems.
- The job is not just to build the requested project, but to make it usable from the local prefix and verify that result.

## First Pass

Before choosing an install method, inspect the real environment:

1. Confirm platform and toolchain.
   Check `uname -s`, `uname -m`, `sw_vers`, `xcode-select -p`, `clang --version`, `cmake --version`, `pkg-config --version`, and whether `make` or `ninja` exist.

2. Confirm the effective prefix and search paths.
   Prefer the live environment over assumptions:
   - `PREFIX`
   - `PATH`
   - `PKG_CONFIG_PATH`
   - `CMAKE_PREFIX_PATH`
   - `CPPFLAGS`
   - `CFLAGS`
   - `CXXFLAGS`
   - `LDFLAGS`

3. Inspect what is already installed locally before downloading anything.
   Fast probes:
   - `pkg-config --list-all`
   - `find "$PREFIX"/lib/pkgconfig`
   - `ls "$PREFIX"/include`
   - `ls "$PREFIX"/lib`
   - `command -v brew`, `command -v port`, and other package managers only to understand options, not to change the install target

4. Read the upstream build instructions and top-level build files.
   Prefer the project's actual install knobs over generic guesses.

## Prefix Rules

- Always use `"$PREFIX"` in commands if it exists in the environment.
- Only fall back to `$HOME/.local` if `PREFIX` is unset.
- Keep include/library discovery aligned with the chosen prefix:
  - `CPPFLAGS="-I$PREFIX/include"`
  - `CFLAGS="-I$PREFIX/include"`
  - `CXXFLAGS="-I$PREFIX/include"`
  - `LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"`
  - `PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"`
  - `CMAKE_PREFIX_PATH="$PREFIX"`
- Do not invent `lib64` paths unless the project or machine actually uses them.

## Install Strategy

Prefer the simplest viable method in this order:

1. Official prebuilt archives that can be unpacked cleanly under `"$PREFIX"`.
2. Release tarballs with a normal prefix-aware source build.
3. Tagged source releases from the upstream repo when tarballs are missing.
4. Project-specific bootstrap scripts only after reading them.

Do not default to Homebrew or MacPorts prefixes when this skill is in use.

## Build System Mapping

Use the project's native install controls:

- Autotools: `./configure --prefix="$PREFIX"`
- CMake: `-DCMAKE_INSTALL_PREFIX="$PREFIX"` and, when local deps are involved, `-DCMAKE_PREFIX_PATH="$PREFIX"`
- Meson: `meson setup build --prefix "$PREFIX"`
- Plain Makefiles: inspect `PREFIX`, `DESTDIR`, `BINDIR`, `LIBDIR`, `INSTALL_PREFIX`
- Cargo: `cargo install --root "$PREFIX"`
- Go: prefer the repo's install target; otherwise land binaries in `"$PREFIX/bin"`
- Python CLI tools: prefer isolated prefix-aware installs
- Node CLI tools: prefer local prefix-aware installs with wrappers in `"$PREFIX/bin"`

## Dependency Triage

Handle dependencies efficiently instead of discovering them one fatal error at a time.

1. Classify dependencies into:
   - hard requirements to configure
   - optional features that can be disabled
   - feature-specific runtime requirements

2. Before the first configure, inspect the project's feature toggles from the real build files.
   For CMake projects, search `CMakeLists.txt` and module files for `option(...)`, `find_package(...)`, and `pkg_check_modules(...)`.

3. Probe whether the local prefix already exposes each likely dependency.
   Prefer `pkg-config`, local include/lib checks, and CMake package files.

4. If a dependency is missing:
   - disable it if it is optional and not needed for the user's stated goal
   - build and install it locally first if it is required for the goal

5. Distinguish between:
   - "minimal install that compiles"
   - "sufficient install for the user's failing feature"
   - "maximal feature matrix"
   State which one you are delivering.

Example: if the user reports a DCT or JPX decoding failure, prioritize local `libjpeg` and `openjpeg` before chasing unrelated optional features.

## Build Directory Hygiene

- Prefer out-of-tree builds.
- Inspect any existing build directory before reusing it.
- If the cache has stale options, wrong compilers, or the previous build profile differs from the new goal, create a fresh build directory.
- Name build directories by intent when useful, for example:
  - `build-minimal`
  - `build-full`
  - `build-utils`
- Clean old build trees only when no longer needed and only after understanding what they contain.

## Efficiency Rules

- Parallelize read-only discovery work whenever possible.
- Avoid repeated full reconfigure cycles by identifying likely missing dependencies early.
- If the machine lacks a package manager on `PATH`, stop assuming one exists and pivot immediately to source dependencies or prebuilt archives.
- Reuse successfully built local dependencies across installs instead of rebuilding them again.
- Keep temporary source and build artifacts in a predictable temporary root and remove them when the task is complete, unless the user wants them retained.

## Escalation Rules

- If network access is needed, fetch only what is necessary for the chosen strategy.
- If sandboxing blocks writes to `"$PREFIX"` or network fetches, request escalation for the exact command that needs it.
- Prefer narrow escalation requests such as:
  - downloading a specific tarball
  - running `cmake --install`
- Do not silently switch strategies because of sandboxing.

## Verification

Verification must match the artifact type:

- Binaries:
  - confirm the binary exists under `"$PREFIX/bin"`
  - run `tool --version` or equivalent
  - check runtime linkage with `otool -L` when relevant
- Libraries:
  - confirm headers and libraries are installed under `"$PREFIX/include"` and `"$PREFIX/lib"`
  - verify with `pkg-config`, CMake package files, or a linker probe
- Feature-specific rebuilds:
  - confirm the rebuilt library links to the dependency that fixed the issue
  - when possible, verify the failing command path directly

If verification is incomplete, say exactly what was confirmed and what remains unverified.

## Operating Rules

- Read upstream instructions before executing project-specific commands.
- Prefer tagged releases over arbitrary branches unless the user asked for HEAD.
- Do not mutate shell startup files unless the user asks.
- If PATH or env changes are still needed, state them explicitly instead of editing configs.
- Do not claim a build is "full-featured" unless the relevant optional features are actually enabled.
- If the user asks for "full-featured" but the machine lacks several optional dependencies, explain the gap precisely and prioritize the features that matter to their actual failure.

## Output Expectations

When finishing an install task:

- state what was installed
- state the effective prefix used
- state which important features are enabled and disabled
- state any dependencies installed as part of the job
- state how the result was verified
- state any remaining caveats
