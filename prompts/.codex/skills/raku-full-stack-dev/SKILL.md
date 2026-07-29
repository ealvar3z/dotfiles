---
name: raku-full-stack-dev
description: Build, refactor, review, and debug full-stack Raku applications for Raku++, including CLI entrypoints, modules, HTTP or TCP services, parsers and serializers, persistence adapters, concurrency, and Raku.js or WebAssembly browser features. Use when Codex needs to design or implement Raku application architecture while following Raku++-compatible, data-oriented Raku style.
---

# Raku Full-Stack Development

Build applications from explicit data flows. Prefer native Raku data and small
transformations; introduce objects only where identity, lifecycle, or behavioral
polymorphism makes them the clearer model.

Treat the active Raku++ checkout, its documentation, and observed `rakupp`
behavior as the source of truth. Use Rakudo as a behavioral comparison when
semantics are uncertain, never as an implementation template.

## Start With Reality

1. Inspect the repository, its agent instructions, module layout, tests, and
   existing Raku style before proposing an architecture.
2. Locate the active `rakupp` executable and read the relevant current Raku++
   documentation. Check features rather than relying on remembered coverage or
   version numbers.
3. Run the smallest existing program or test that exercises the relevant
   surface. Confirm module loading, network APIs, native compilation, or Raku.js
   behavior when the task depends on it.
4. Preserve an existing application's conventions unless they conflict with
   correctness, Raku++ compatibility, or the user's explicit data-oriented goal.

When working inside the Raku++ repository, consult the focused documents for the
feature being used: modules, networking, async behavior, Raku.js, parsing,
runtime semantics, linting, and compilation. Read the matching showcase program
as executable design evidence.

## Design the Data Flow

Describe each feature as:

```text
external input
  -> boundary parser or adapter
  -> canonical native Raku data
  -> domain transformations
  -> result data
  -> serializer or side-effect adapter
```

Make the canonical shapes visible. Use `%` for associative state, `@` for
positional state, and `$` for a single item. Keep protocol, storage, HTML, JSON,
and process I/O at the edges. Keep domain transformations callable without a
socket, database, browser, or global environment.

Read [references/rakupp-style.md](references/rakupp-style.md) before designing,
refactoring, or reviewing domain code. Read
[references/full-stack-patterns.md](references/full-stack-patterns.md) when the
task crosses a process, network, storage, or browser boundary.

## Choose Raku Constructs Deliberately

- Represent ordinary records and trees with native `Hash`, `Array`, `List`,
  `Pair`, and scalar values.
- Express transformations as small typed `sub`s. Use `multi` when dispatch on
  data type or shape is the domain rule, and `given`/`when` for clear protocol
  dispatch.
- Use a `grammar` plus actions at structured-text boundaries. Make actions
  produce native values, then leave parsing objects behind.
- Use modules and `is export` to establish boundaries. Keep the entrypoint in
  `MAIN` and keep orchestration thin.
- Use classes or roles for genuine behavioral protocols, resource lifecycles,
  identity-bearing state, grammar actions, exceptions, and unique sentinels.
- Avoid anemic entity classes, deep inheritance, service-object layers,
  getters around hashes, and classes created only to group unrelated functions.
- Localize mutation. Pass state explicitly when practical. Guard shared mutable
  arrays, hashes, or objects with `Lock` whenever parallel execution is possible.
- Use Promises, Supplies, and Channels for concurrency only when they clarify
  ownership and flow; do not make a synchronous transformation asynchronous by
  default.

## Respect Raku++ Boundaries

- Prefer capabilities demonstrated by current Raku++ docs, tests, or showcases.
- Test every ecosystem dependency with `rakupp`. A failed `use` can warn and
  continue under Raku++, so do not mistake process survival for a loaded module.
  Check the imported capability or fail startup explicitly when it is required.
- Do not depend on macros, slangs, arbitrary parse-time grammar mutation, or
  NativeCall-heavy modules without proving the active Raku++ build supports the
  exact use.
- Keep Raku.js code free of server sockets and native threads. Keep recursion
  shallow enough for the browser build. Put DOM and browser API access in a thin
  JavaScript host unless the active bridge exposes and verifies another route.
- Do not promise Rakudo parity automatically. When parity is required, test both
  engines and stay inside their verified common behavior.
- Prefer direct Raku++ APIs over framework assumptions. Introduce an ecosystem
  framework only after verifying that it loads and its required path executes.

## Implement in Thin Slices

1. Define representative input and output data, including errors.
2. Implement and test the domain transformation without external I/O.
3. Add one boundary adapter: CLI, file, protocol, persistence, or browser.
4. Exercise one successful request end to end.
5. Add malformed input, missing data, dependency failure, and shutdown behavior
   relevant to that boundary.
6. Add concurrency only after the serial data flow is correct.
7. Compile natively or bundle for Raku.js only after interpreter behavior passes.

Prefer the smallest change that is semantically correct. Do not hide a Raku++
gap behind a silent fallback or reimplement a standard feature without first
checking the active runtime.

## Verify

Use the project commands when they exist. Otherwise adapt this sequence to the
active executable and paths:

```sh
rakupp --check app.raku
rakupp --lint app.raku
rakupp -I lib app.raku
rakupp --exe -o app app.raku
./app
```

For each changed behavior:

- Test pure transformations with table-shaped inputs and expected data outputs.
- Test boundary parsing and serialization separately from domain logic.
- Exercise missing, malformed, empty, Unicode, and large inputs where applicable.
- Exercise dependency-load failure when an external module is required.
- Exercise shared-state behavior in both default mode and
  `RAKUPP_PARALLEL=1` when concurrency is in scope.
- Run the native executable for deployment-sensitive work; interpreter success
  alone is insufficient.
- Build and run the Raku.js artifact for browser work; native success alone is
  insufficient.
- Compare observable output with Rakudo only when parity is an acceptance
  criterion or a language-semantic question needs an oracle.

Report the exact commands run, the observed result, and any unverified runtime
surface. Never describe a module, native build, or browser path as working based
only on static inspection.
