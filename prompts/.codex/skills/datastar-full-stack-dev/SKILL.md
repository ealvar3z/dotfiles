---
name: datastar-full-stack-dev
description: Build, refactor, review, and debug backend-driven Datastar applications with Raku++ or Go. Use when Codex needs to design Datastar architecture, render reactive HTML with data-* attributes, handle Datastar backend actions, stream patch-elements or patch-signals events over SSE, implement real-time or collaborative flows, replace SPA state or polling, create a Raku++ Datastar adapter, or use the official Datastar Go SDK while following the creator's state-in-the-right-place philosophy.
---

# Datastar Full-Stack Development

Build around one axiom: state in the wrong place causes most real-world
problems. Keep authoritative application facts at the backend, user intent near
the user, and rendering near the browser.

Use the browser as a purpose-built hypermedia engine. Send declarative HTML and
small signal patches instead of recreating routing, rendering, reconciliation,
and server truth in a client-side application framework.

## Ground the Work

1. Inspect repository instructions, existing language, templates, routes,
   tests, and deployment constraints.
2. Prefer an existing Raku++ or Go backend. Do not introduce a second backend
   language just to use Datastar.
3. Find the active Datastar version. When a Datastar checkout is available,
   read `sdk/README.md`, `sdk/ADR.md`, `sdk/datastar-sdk-config-v1.json`, and
   relevant golden tests. Otherwise consult the current official guide,
   reference, and SDK documentation.
4. Verify current attribute, action, event, and SDK syntax before coding.
   Preserve the architectural principles in this skill even when APIs change.
5. Exercise the smallest existing page and backend action before redesigning
   the application.

Read [references/creator-principles.md](references/creator-principles.md) before
making architectural or state-placement decisions. Read
[references/protocol.md](references/protocol.md) before implementing requests,
SSE events, compression, or a language adapter.

## Place State Deliberately

Classify each fact before implementing it:

| Kind of state | Preferred owner |
|---|---|
| Durable facts, permissions, workflow status, shared state | Backend |
| Submitted form values and attempted actions | User-facing controls/signals |
| Pending, loading, or retry state | Browser representation of intent |
| DOM, focus, selection, native control state | Browser |
| Imperative widget internals | Isolated Web Component |

Keep signals sparse. Use them for user input, local interaction, and data sent
to the backend—not as a duplicate client database. Never show success before
the authority confirms it. Show the attempted action or pending state
immediately, then let the backend stream the confirmed result or error.

## Design the Flow

Describe every vertical slice as:

```text
user event
  -> declarative Datastar action
  -> HTTP request carrying filtered signals
  -> boundary decoder
  -> authoritative domain transformation
  -> rendered complete HTML elements and/or signal patch data
  -> SSE response
  -> browser morph and reactive expressions
```

Prefer:

- Semantic HTML, links, forms, and native browser behavior.
- Declarative `data-*` attributes for bindings, events, computed presentation,
  indicators, and backend actions.
- Server-rendered complete elements with stable IDs.
- Default outer morphing and coherent, sometimes large, render regions.
- SSE responses for ordinary mutations and streaming reads.
- A long-lived read stream plus short-lived write requests when CQRS makes
  real-time collaboration simpler.
- Compression and server-controlled throttling for repeated streamed markup.

Do not default to:

- Optimistic success claims.
- Polling when the backend can own an update stream.
- WebSockets when normal HTTP requests and SSE satisfy the requirements.
- Fine-grained client mutations that duplicate server rendering.
- A client router or client-side state store for facts already owned by the
  backend.
- Arbitrary page-level JavaScript. Isolate genuine imperative behavior behind a
  Web Component with explicit properties and events.

## Choose the Backend

Honor an explicit language and preserve an existing repository's language.

- For Raku++, read [references/rakupp-backend.md](references/rakupp-backend.md)
  and apply the installed `raku-full-stack-dev` skill when available. Use a thin
  adapter over the documented wire protocol unless a currently verified Raku
  SDK exists.
- For Go, read [references/go-backend.md](references/go-backend.md) and apply
  the installed `go-best-practices` skill when available. Prefer the official
  Datastar Go SDK.
- For a neutral greenfield task, compare both paths against the actual
  requirements. Present both when neither has a material advantage; do not
  invent a universal language winner.

## Implement in Thin Slices

1. Render a complete initial page with semantic HTML.
2. Add the minimum signals required for user input or local presentation.
3. Implement one backend action and decode its signal data.
4. Apply domain logic at the backend.
5. Render the authoritative result as complete elements.
6. Return a valid SSE response and verify it in a real browser.
7. Add pending intent, rejection, malformed input, cancellation, and
   disconnect behavior.
8. Add a long-lived stream only when the product needs live updates.
9. Add compression, throttling, or concurrency after correctness is measured.

Keep domain transformations independent from HTTP, SSE, HTML, and persistence
when practical. Make renderers ordinary functions over explicit data. Keep
transport objects at the boundary.

## Verify the System

- Test domain transformations with table-shaped cases.
- Test rendered HTML as strings or parsed DOM, including escaping and stable
  IDs.
- Test signal decoding for GET/DELETE query data and write-method JSON bodies.
- Compare SSE output with the active Datastar SDK golden tests when implementing
  or changing an adapter.
- Exercise multiple ordered events, multiline elements/signals, defaults,
  non-default options, invalid JSON, disconnects, and failed writes.
- Test pending intent and backend rejection without ever displaying false
  success.
- Inspect the browser network stream and final DOM. Use the Datastar Inspector
  when available.
- Measure before adding client state, WebSockets, fine-grained patches, or
  custom JavaScript.
- For streaming production paths, verify proxy buffering, response flushing,
  compression, cancellation, connection limits, and graceful shutdown.

Report exact commands, observed behavior, current Datastar and SDK versions, and
any unverified runtime path.
