# Datastar HTTP and SSE Protocol

Use this reference before implementing backend actions, an SSE writer, or a
language adapter. Treat the active Datastar checkout and official reference as
the final authority when details differ.

## Contents

- Source-of-truth order
- Request flow
- SSE response contract
- Patch elements
- Patch signals
- Script execution
- Streaming operations
- Conformance testing

## Source-of-Truth Order

Use sources in this order:

1. The Datastar version pinned by the application.
2. A matching local Datastar checkout:
   - `sdk/README.md`
   - `sdk/ADR.md`
   - `sdk/datastar-sdk-config-v1.json`
   - `sdk/tests/golden/`
3. Current official documentation:
   - <https://data-star.dev/guide/backend_requests>
   - <https://data-star.dev/reference/actions>
   - <https://data-star.dev/reference/sse_events>
   - <https://data-star.dev/reference/sdks>

Do not mix examples from different Datastar releases.

## Request Flow

Datastar sends filtered frontend signals under the `datastar` key:

| Method | Location |
|---|---|
| `GET`, `DELETE` | URL-encoded `datastar` query parameter |
| `POST`, `PUT`, `PATCH` | JSON request body |

Decode into an explicit backend data shape. Reject malformed JSON and invalid
domain input before mutating authoritative state.

Datastar backend actions normally set `Datastar-Request: true` and request an
SSE response. Treat headers as transport metadata, not authorization.

## SSE Response Contract

Set:

```text
Cache-Control: no-cache
Content-Type: text/event-stream
Connection: keep-alive
```

Only emit `Connection: keep-alive` where appropriate for HTTP/1.1. Do not emit
HTTP/1.1 hop-by-hop headers into HTTP/2 or HTTP/3.

Format each event in this order:

```text
event: EVENT_TYPE
id: EVENT_ID
retry: RETRY_MILLISECONDS
data: DATA_LINE
data: ANOTHER_DATA_LINE

```

- Omit `id` when absent.
- Omit `retry` when it equals the default, currently 1000 ms in the local v1
  SDK configuration.
- Prefix every logical data line with `data: `.
- End every event with a blank line.
- Preserve event order.
- Flush promptly where the HTTP implementation supports it.
- Return or propagate write and flush failures.
- Serialize concurrent writes to the same response.
- Stop work when the request is cancelled or the client disconnects.

Compression middleware can delay flushing. Verify actual streaming behavior
through the deployed proxy path.

## Patch Elements

Use event type:

```text
datastar-patch-elements
```

Emit complete HTML elements, not arbitrary text fragments. Without an explicit
selector, give each top-level element a stable ID.

Supported v1 modes in the local SDK configuration:

| Mode | Behavior |
|---|---|
| `outer` | Morph outer element; default |
| `inner` | Morph inner HTML |
| `replace` | Replace target |
| `prepend` | Insert first inside target |
| `append` | Insert last inside target |
| `before` | Insert before target |
| `after` | Insert after target |
| `remove` | Remove target |

Optional data lines include `selector`, `mode`, `useViewTransition`,
`viewTransitionSelector`, and `namespace`. Omit default values unless the active
specification requires them. Supported namespaces are `html`, `svg`, and
`mathml`.

Example:

```text
event: datastar-patch-elements
data: elements <div id="status">Saved</div>

```

For multiline HTML, repeat the `elements` literal:

```text
event: datastar-patch-elements
data: selector #items
data: mode append
data: elements <li id="item-42">
data: elements   New item
data: elements </li>

```

Prefer the default outer morph. Use explicit selectors and non-morphing modes
for a concrete reason, not as a substitute for a coherent renderer.

## Patch Signals

Use event type:

```text
datastar-patch-signals
```

Send valid JSON using RFC 7386 JSON Merge Patch semantics:

- Add or update with a value.
- Remove a signal by setting it to `null`.
- Patch nested objects recursively.

Example:

```text
event: datastar-patch-signals
data: signals {"pending":false,"error":null}

```

Use `onlyIfMissing true` only when initializing absent signals. Keep signal
patches small and user-facing; render authoritative domain state as HTML when
that is clearer.

## Script Execution

Treat server-triggered script execution as an escape hatch. The v1 SDK contract
models it as a `datastar-patch-elements` event that appends a `<script>` element
to `body`, commonly with a self-removing `data-effect`.

Prefer a declarative attribute, native browser behavior, redirect, or explicit
Web Component interface. Escape untrusted values for JavaScript and HTML
contexts separately.

## Streaming Operations

For a long-lived stream:

- Send a coherent initial state promptly.
- Choose an explicit freshness or batching policy at the backend.
- Coalesce updates when clients cannot consume every intermediate state.
- Use bounded queues or latest-value semantics; do not allow unbounded
  per-client buffers.
- Propagate cancellation to producers.
- Consider heartbeat comments only when intermediaries require traffic.
- Enable streaming-compatible Brotli, zstd, or gzip when the deployed stack and
  clients support it.
- Disable proxy buffering and verify it empirically.
- Treat retries as reconnects that may require replay, an event ID, or a fresh
  authoritative snapshot.

## Conformance Testing

When implementing or changing an adapter:

1. Start a disposable `/test` endpoint.
2. Decode the `events` array supplied by the Datastar SDK tests.
3. Generate events in the requested order.
4. Run the matching local test runner or current published runner.
5. Compare against `sdk/tests/golden/`.

Cover:

- GET query and POST body signal decoding.
- Defaults and every non-default option used.
- Multiple ordered events.
- Multiline elements, signals, and scripts.
- Element and signal removal.
- Invalid JSON and invalid modes.
- Disconnects and write failures.

Do not call an adapter compatible based only on a successful compile.
