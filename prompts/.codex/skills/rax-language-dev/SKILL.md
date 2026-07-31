---
name: rax-language-dev
description: Design, implement, review, and evolve Rax (Raku Expressions), a pure software-deployment language and content-addressed store written in data-oriented Raku for Raku++. Use for Rax syntax, grammar, evaluation, canonical IR, hashing, realization, profiles, garbage collection, caches, tests, and patch planning.
---

# Rax Language Development

Build Rax as a small deployment calculus, not as Nix rewritten in Raku. Preserve
Nix's durable mechanisms while avoiding accidental complexity in its language,
evaluator, CLI, and ecosystem.

Use `$raku-full-stack-dev` for general Raku++ style, repository inspection,
modules, process boundaries, concurrency, and verification. This skill contains
only the Rax-specific architecture and workflow.

## Project Invariants

Hold these unless the user explicitly changes them:

- `.rax` is a pure external DSL parsed by a Raku `grammar` plus actions.
- Do not use slangs, macros, RakuAST, arbitrary parse-time mutation, or `EVAL`.
- Compile the implementation with `rakupp`; verify uncertain behavior against
  the active compiler rather than memory.
- Evaluation is eager and deterministic by default.
- Parsing, evaluation, lowering, realization, storage, and policy are separate.
- Surface syntax lowers to a small, versioned, canonical Plan IR.
- Hash semantic data, never source spelling, `.raku` output, or native hash
  iteration order.
- Keep plan identity separate from realized content identity.
- Store objects are immutable; profiles are atomic roots into the store.
- Build operations are structured data. Shell is an explicit escape hatch.
- Runtime references are declared; output scanning verifies them.
- Network access belongs to explicit fetchers, not evaluation or normal builds.
- Begin with a daemonless, per-user, POSIX store.

## Preserve the Pipeline

Keep the implementation readable as:

```text
.rax source
  -> grammar and actions
  -> surface AST with source spans
  -> pure evaluator
  -> validated canonical Plan IR
  -> PlanId
  -> realizer
  -> normalized output tree
  -> ObjectId and realization record
  -> profile or cache policy
```

Later layers must not interpret surface syntax. The store and realizer consume
Plan IR, not parser nodes.

Represent AST and IR primarily with immutable `Map`, `List`, `Pair`, `Set`, and
scalar values. Use `enum` for finite tags, `proto` and `multi` for evaluation and
encoding, and `given`/`when` for tagged-data dispatch. Use classes only for
behavioral boundaries such as grammar actions, exceptions, or stateful resources;
do not build an AST class hierarchy merely to name record shapes.

The canonical Plan IR should admit only deliberate semantic values:

```text
Nil Bool Int Rat Str Path List Map Set Source Input Output Step Plan
```

Reject arbitrary runtime objects, callables, matches, floating-point values, and
ambient resources before canonical encoding.

## Preserve Dual Identity

Define identities conceptually as:

```text
PlanId   = digest(canonical Plan IR)
ObjectId = digest(canonical normalized output tree)
```

A realization maps a plan, platform, and named output to an object plus its
references and attestations. Carry the digest algorithm in every identifier; do
not collapse `PlanId` and `ObjectId` for convenience.

Canonical encoding must use explicit type tags and lengths, normalized UTF-8,
normalized rationals, preserved list order, maps and sets sorted by encoded
bytes, normalized paths, and no timestamps, locale dependence, or host order.
Version the format from its first byte.

## Respect Raku++ Boundaries

- Treat the active Raku++ checkout, its documentation, tests, and observed
  `rakupp` behavior as authoritative for Rax.
- Do not require Rakudo compatibility, run Rakudo parity tests, or constrain
  Rax around Rakudo behavior unless explicitly requested.
- When diagnosing ambiguous Raku semantics, consult the Raku specification or
  another implementation only as investigative evidence. Do not convert that
  comparison into a Rax compatibility requirement.
- When Rax depends on undocumented or recently implemented compiler behavior,
  capture it in a focused `rakupp` regression test.

## Work One Milestone at a Time

### Milestone 0: Language Core

Implement only:

- grammar, actions, and source spans;
- immutable surface AST;
- pure evaluator and validation;
- canonical Plan IR and encoding;
- digest abstraction and `PlanId`;
- `rax parse`, `rax check`, `rax eval`, and `rax plan`;
- interpreted/native Raku++ equivalence tests.

Do not add a builder, store, profiles, cache, or garbage collector yet.

Acceptance requires:

- whitespace and map insertion order do not change `PlanId`;
- semantic changes do change it;
- diagnostics include file, line, column, and useful context;
- canonical output is byte-identical under interpreted `rakupp`, and a
  `rakupp --exe` binary;
- repeated runs under the same pinned `rakupp` release produce byte-identical
  canonical output and `PlanId` values;
- evaluation performs no process, network, clock, environment, or arbitrary
  filesystem effects.

### Later Milestones

Proceed in order unless redirected:

1. immutable local store and realization records;
2. structured build steps and one trivial local build;
3. profiles, generations, atomic rollback, and runtime leases;
4. reachability-based garbage collection with explanations;
5. fixed-output HTTPS, Git, and local-tree fetchers;
6. signed cache pull and push;
7. parallel and remote realization;
8. package collection and higher-level policy.

Do not implement future layers early.

## Keep Effects at Boundaries

Pure routines receive explicit data. They do not inspect `%*ENV`, run commands,
read arbitrary files, use the network, or consult time.

A realizer receives only declared inputs, outputs, temporary storage, normalized
environment data, target data, and explicit capabilities. Describe its actual
isolation honestly as normalized, isolated, or hermetic. Do not hide side effects
inside actions, validators, canonical encoders, `map`, or `grep`.

## Patch Deliberately

Inspect the tree, tests, current patch series, and active milestone before
editing. Prefer small numbered patches under `patches/`:

```text
00-project-charter.patch
01-repository-skeleton.patch
02-grammar-and-spans.patch
03-surface-ast.patch
04-pure-evaluator.patch
05-plan-ir.patch
06-canonical-encoding.patch
07-plan-hashing.patch
08-cli-and-native-equivalence.patch
```

Keep every patch buildable, reviewable, and limited to one architectural move.
Do not add `AGENTS.md`; this skill is the Rax project guidance.

## Verify Used Surfaces

Use repository commands when present. Otherwise adapt:

```sh
rakupp --lint bin/rax
rakupp -I lib bin/rax check examples/hello.rax

rakupp -I lib bin/rax plan examples/hello.rax > /tmp/rax.plan.1
rakupp -I lib bin/rax plan examples/hello.rax > /tmp/rax.plan.2
cmp /tmp/rax.plan.1 /tmp/rax.plan.2

rakupp -I lib --exe bin/rax -o /tmp/rax
/tmp/rax plan examples/hello.rax > /tmp/rax.native.plan
cmp /tmp/rax.plan.1 /tmp/rax.native.plan
```

Test valid, malformed, empty, Unicode, duplicate-key, ordering, normalization,
and unsupported-value cases. Report exact commands, results, changed files,
patch boundaries, and unverified `rakupp` behavior. Never hide an unsupported
feature behind a semantically different fallback.
