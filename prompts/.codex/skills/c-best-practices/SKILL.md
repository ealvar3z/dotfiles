---
name: c-best-practices
description: Practical C guidance for writing and reviewing code with emphasis on correctness, maintainability, portability, and matching the existing codebase style.
---

# C Best Practices

Use this skill when writing, reviewing, or refactoring C. The goal is not to impose one house style on every repository; the goal is to produce correct, maintainable C that matches the local codebase unless the user explicitly asks for a new convention.

## When to Use

- Writing new C source or header files
- Reviewing C code for bugs, safety issues, or maintainability problems
- Refactoring C modules or APIs
- Answering questions about C style, structure, portability, or common pitfalls

## Core Rule

Match the repo first.

Before making style decisions, inspect nearby C files, headers, formatting config, build flags, and lint settings. If the repository already has conventions, follow them. Only propose a new convention when:

- the repo has no clear convention,
- the existing pattern is actively harmful, or
- the user explicitly asks for a different style.

## What to Check First

Read enough local context to answer these questions:

- How are files organized: one module per file, feature-based layout, or something else?
- What naming style is already used for types, functions, macros, and locals?
- Is there an existing formatter such as `clang-format`?
- Which warning flags are enabled in the build?
- Does the code target C89, C99, C11, C17, embedded C, POSIX, or platform-specific APIs?
- Are ownership, memory allocation, and error handling patterns already established?

## Priorities

Apply these priorities in order:

1. Correctness
2. Memory safety and lifetime clarity
3. API clarity
4. Maintainability
5. Portability
6. Style consistency

## Writing Guidance

### Interfaces and Headers

- Keep headers minimal and stable.
- Expose only what other translation units need.
- Prefer forward declarations in headers when possible to reduce coupling.
- Use include guards or `#pragma once` only if the repo already accepts it.
- Keep public headers free of unnecessary internal macros and private helpers.

### Includes

- Follow the repo's include order if it exists.
- Otherwise prefer: own header first in `.c` files, then system headers, then project headers.
- Include what you use; do not rely on transitive includes.

### Naming

- Reuse the naming scheme already present in the codebase.
- Favor descriptive names over abbreviation-heavy names unless the domain already uses them.
- Make macro names distinctive and scoped to the module to avoid collisions.
- Reserve leading underscores and double underscores for the implementation/compiler; do not invent identifiers with those forms.

### Types and Data

- Prefer `size_t` for sizes and indexes into object sizes.
- Use fixed-width integer types when bit width matters.
- Use `bool` from `<stdbool.h>` when the project standard allows it.
- Keep struct invariants simple and document ownership of pointer fields when it is not obvious.
- Avoid exposing struct internals publicly unless callers must manipulate fields directly.

### Functions

- Keep functions small enough to read in one pass.
- Give each function one clear responsibility.
- Make internal helpers `static`.
- Prefer explicit parameters over hidden global state.
- Document ownership transfer, mutability, and error behavior for non-trivial APIs.

### Memory and Ownership

- Make allocation and free paths easy to trace.
- On failure paths, clean up in the reverse order of acquisition.
- Use a single cleanup path with `goto cleanup` when a function has multiple owned resources.
- Initialize variables before use; prefer zero-initialization when it matches the type semantics.
- After `free`, only null out the pointer when that prevents a real reuse bug or matches repo practice.

### Error Handling

- Check return values from allocations, I/O, parsing, locking, and system calls.
- Propagate errors with enough context to debug them.
- Prefer consistent error conventions within a module: `int` status, enum status, or `NULL` plus diagnostics.
- Do not hide recoverable errors behind `assert`.
- Use `assert` for programmer invariants, not runtime input validation.

### Control Flow

- Keep branching shallow where practical.
- Prefer early returns for invalid input and guard conditions when that improves clarity.
- In `switch` statements, handle each enumerated case intentionally and comment on fallthrough when used.
- Avoid clever macro control flow when a normal function is clearer.

### Macros

- Prefer `static inline` functions over function-like macros when type safety matters.
- Parenthesize macro parameters and the full expansion.
- Avoid macros with hidden side effects or multiple evaluation of arguments.
- Keep multi-line macros rare and obvious.

### Concurrency and Signals

- Be explicit about thread-safety assumptions.
- Protect shared mutable state consistently.
- In signal handlers, call only async-signal-safe functions.
- Do not treat `volatile` as a synchronization primitive.

### Portability

- Avoid assuming pointer size, integer size, endianness, or struct packing.
- Be careful with signed/unsigned conversions.
- Use the correct format specifiers for the actual type.
- Distinguish POSIX-only code from portable ISO C code.

## Review Checklist

When reviewing C code, look for these first:

- buffer overflows, off-by-one errors, and unchecked lengths
- use-after-free, double-free, leaks, and unclear ownership
- missing error checks or inconsistent error propagation
- integer truncation, overflow, signedness bugs, and bad format strings
- null dereferences and invalid lifetime assumptions
- hidden global state and non-reentrant helpers
- header coupling, missing `static`, and overexposed internals
- macros that should be functions
- style changes that break local consistency without benefit

## Editing Rules

- Preserve the repo's existing formatting unless the task is specifically to reformat.
- Do not rename public APIs casually.
- Avoid mixing behavioral changes with broad style churn.
- If you introduce a new pattern, use it consistently within the touched area.
- Add brief comments only where they clarify invariants, ownership, or non-obvious control flow.

## Verification

After changes, do the strongest verification the repo supports:

- run the relevant build
- run focused tests
- enable warnings if practical
- mention any checks you could not run

## Output Guidance

When using this skill in a review or recommendation:

- lead with correctness and safety findings
- distinguish repo-specific style from general C best practice
- explain tradeoffs when suggesting API or ownership changes
- keep advice concrete and tied to the code under discussion
