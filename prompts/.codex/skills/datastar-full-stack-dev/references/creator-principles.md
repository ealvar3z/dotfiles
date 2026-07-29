# Datastar Creator Principles

Use this reference for architecture, state placement, and review. It distills
Delaney Gillilan's creator presentation in `presentation.txt`; it is not an API
reference.

## Contents

- Foundational axiom
- Purpose-built engines and declarative data
- State ownership
- Three recurring failure modes
- Hypermedia and transport
- Rendering and compression
- Custom browser behavior
- Testing and measurement
- Review questions

## Foundational Axiom

Treat "state in the wrong place is the cause of most real-world problems" as the
starting hypothesis.

The web is a distributed system. Do not pretend the browser and backend share a
single synchronous state machine. Place each fact with the component that can
authoritatively know it:

- Facts, permissions, shared state, and success belong at the backend.
- Perception and native control state belong in the browser.
- Intent belongs near the user who expressed it.
- Imperative widget state belongs inside a narrow widget boundary.

Do not duplicate authoritative state merely to make a frontend framework feel
local. Every duplicate creates synchronization, rollback, and stale-data work.

## Purpose-Built Engines and Declarative Data

Prefer a purpose-built engine plus declarative data. The browser already knows
how to parse HTML and CSS, lay out pixels, navigate resources, preserve form and
focus state, expose accessibility semantics, execute Fetch, and maintain
history.

Give the browser HTML, CSS, and declarative `data-*` expressions. Let Datastar
connect signals and actions. Avoid rebuilding a virtual browser inside a
general-purpose JavaScript runtime.

Keep the Datastar layer small and plugin-oriented. Application complexity should
remain in the application's domain, not in framework ceremony.

## State Ownership

Use the backend as the primary source of truth. Render what is currently true
and stream it to the browser. Use frontend signals sparingly for:

- Form input and other user-supplied data.
- Local visual interaction.
- Pending intent.
- Values that must accompany a backend request.

Do not preload a broad client-side model and assume it stays current. Do not
require the browser to reconcile domain truth with its own speculative copy.

## Three Recurring Failure Modes

### Optimistic Updates Lie

An optimistic UI claims an operation succeeded before the authority confirms
it. A rollback cannot erase the period in which the interface lied.

Use instant intent:

1. Represent the user's attempted action immediately.
2. Mark it pending or in progress.
3. Send the command to the backend.
4. Let the backend validate and mutate authoritative state.
5. Stream confirmed truth or a clear rejection.

Fast feedback does not require false success.

### Custom Code Is Imperative

Some interfaces genuinely need imperative behavior. Contain it rather than
letting it own the application.

Use a Web Component when behavior requires a canvas, editor, map, drag surface,
or other lifecycle-bearing browser object. Give the component explicit
properties and events. Let Datastar drive those properties with signals, and
send user intent back through normal events or backend actions.

The Web Component owns its rendering mechanism; the backend still owns domain
facts.

### Polling Produces Stale State

Polling makes every client guess when truth might have changed. It wastes
requests, creates a staleness window, and puts update policy in the least
authoritative place.

Give the backend an SSE stream it can update, throttle, and close. The authority
then controls the freshness SLA and backpressure policy without changing every
client.

## Hypermedia and Transport

SSE is an ordinary HTTP response with `text/event-stream` framing. Datastar
backend actions use Fetch semantics, and responses can contain zero or more
events.

Prefer normal HTTP requests plus SSE to WebSockets unless bidirectional
full-duplex messaging is a demonstrated requirement. HTTP retains familiar
headers, authentication, caching rules, multiplexing, observability, retry
behavior, and compression. Under HTTP/2, multiple writes can share a connection
while an SSE read remains open.

For collaborative systems, consider:

```text
long-lived GET stream for authoritative reads
short-lived POST/PUT/PATCH/DELETE requests for commands
```

This CQRS-shaped split lets many users receive a coherent stream without
granting the browser ownership of shared state.

## Rendering and Compression

Render complete elements at the backend. Prefer coherent snapshots and default
morphing over hand-authored micro-mutations.

Repeated HTML compresses extremely well because tags and structure recur.
Streaming a large render region can therefore be both simpler and smaller than
maintaining client-side reconciliation instructions. Compression also benefits
from a larger rolling window across repeated events.

Start with the clearest render boundary, even the page body or full document
when appropriate. Measure before shrinking patches.

Do not confuse raw uncompressed markup size with bytes transferred over a
compressed stream.

## Custom Browser Behavior

Keep ordinary DOM work declarative. Use semantic HTML and native browser
features first.

When imperative code is unavoidable:

- Isolate it in a Web Component.
- Make its inputs explicit properties or attributes.
- Make its outputs explicit events.
- Keep domain state outside it.
- Test it independently from the backend.

Be a good page steward. Do not assume exclusive ownership of the DOM, navigation,
history, or every event.

## Testing and Measurement

If a backend model renders to an HTML string, test the string or parsed DOM.
Test the server transformation without a browser, then test the thin browser
contract end to end.

Keep browser widgets independently testable. Test protocol framing separately
from domain behavior.

Challenge claims with measurements:

- Dependency and bundle size.
- Transferred bytes after realistic compression.
- Connection count and CPU per core.
- Update freshness and tail latency.
- Memory and power use.
- Lines of application code and operational components.

Do not settle for a small percentage improvement when moving state to the right
place can remove whole categories of work.

## Review Questions

- Which component is authoritative for each fact?
- Does the UI ever claim success before confirmation?
- Could a backend stream replace polling?
- Could ordinary HTTP and SSE replace a WebSocket?
- Are signals carrying user intent or duplicating server state?
- Is the backend rendering coherent complete elements?
- Is imperative browser code isolated behind an explicit component boundary?
- Are native navigation, history, forms, and accessibility semantics preserved?
- Was compressed transfer measured rather than guessed?
- Can domain logic and HTML rendering be tested as ordinary data
  transformations?
