# Raku++ Datastar Backend

Use this reference for Datastar applications implemented with Raku++. Apply the
data-oriented conventions from `raku-full-stack-dev` when that skill is
installed.

## Contents

- Compatibility first
- Data-oriented architecture
- Adapter boundary
- SSE encoding
- HTTP integration
- Concurrency and streaming
- Verification

## Compatibility First

Treat the active Raku++ checkout, its documentation, and observed `rakupp`
behavior as the source of truth.

Before choosing an HTTP library or server API:

1. Inspect the project's existing HTTP stack.
2. Read the matching Raku++ networking, async, module, and JSON documentation.
3. Verify every imported module by exercising a known symbol. Raku++ may warn
   and continue after a failed `use`.
4. Run one real local request under `rakupp`.
5. Confirm that the response API exposes streaming writes, flushing, request
   cancellation, and protocol version information.

Do not claim that a Rakudo ecosystem HTTP framework works under Raku++ without
running the exact path.

No Raku SDK appears in the local Datastar SDK list used to create this skill.
Re-check the current official SDK list before writing an adapter. If a compatible
SDK now exists, test it before preferring it.

## Data-Oriented Architecture

Keep the application flow visible:

```text
HTTP request
  -> %request data
  -> decoded %signals
  -> pure domain transformation
  -> %result
  -> rendered HTML and/or %signal-patch
  -> @SSE lines
  -> response adapter
```

Use native hashes, arrays, lists, pairs, and scalars for request, result, and
event data. Prefer small exported `sub`s for transformations.

Example boundary shapes:

```raku
my %request = method => 'POST', path => '/items', body => $body;
my %result  = ok => True, item => %item;
my %event   = type => 'patch-elements', elements => $html;
```

Keep HTTP request/response objects, sockets, environment variables, and
persistence handles outside domain routines.

Use a class only when it protects the lifecycle and ordering of a live response
or another real resource. Do not create controller, service, repository, and
event classes around record-shaped data.

## Adapter Boundary

A small Raku++ Datastar adapter should expose ordinary routines over data:

```raku
sub read-signals(%request --> Hash) is export { ... }
sub encode-sse(%event --> Str) is export { ... }
sub patch-elements(Str $html, *%options --> Hash) is export { ... }
sub patch-signals(%signals, *%options --> Hash) is export { ... }
```

Represent events as data until the final write. This makes protocol tests
independent from the HTTP server.

Use JSON parsing and URL decoding proven by the active Raku++ build. Reject
invalid JSON explicitly.

Keep event names, patch modes, defaults, and dataline literals in one module.
Derive them from the active Datastar SDK configuration when generating an SDK;
do not scatter string constants through handlers.

## SSE Encoding

Encode one event deterministically:

```raku
sub encode-sse(%event --> Str) {
    my @lines = "event: {%event<event-type>}";

    @lines.push("id: {%event<event-id>}")
        if %event<event-id>:exists;
    @lines.push("retry: {%event<retry>}")
        if %event<retry>:exists && %event<retry> != 1000;

    for %event<data-lines>.List -> $line {
        @lines.push("data: $line");
    }

    @lines.join("\n") ~ "\n\n"
}
```

Verify this example under the active Raku++ version before copying it into an
application. Preserve every logical HTML or JSON line as a separate `data:`
line. Do not use `.trim`, which could alter meaningful content.

Build patch-element data in protocol order. Omit defaults. Require complete
elements and stable IDs when no selector is provided.

Serialize signal hashes with a verified JSON encoder. Preserve JSON `null` for
removal semantics; do not accidentally turn it into an absent Raku value before
encoding.

## HTTP Integration

At the response boundary:

- Set `Cache-Control: no-cache`.
- Set `Content-Type: text/event-stream`.
- Set `Connection: keep-alive` only for HTTP/1.1.
- Write bytes using the server's documented streaming API.
- Flush after complete events when supported.
- Surface write and flush errors.
- Stop producing events when the request is cancelled.

Keep the handler thin:

```raku
sub handle-create(%request, %state is rw --> Hash) {
    my %signals = read-signals(%request);
    my %result  = create-item(%signals, %state);
    patch-elements(render-items(%state), pending => False)
}
```

Adapt exact signatures to the project. Do not pass a live response into domain
or rendering routines.

Escape untrusted values for their HTML context. Use a small explicit escaping
routine or a verified template system rather than interpolation of raw user
data.

## Concurrency and Streaming

Give one component clear ownership of a live response. If several producers can
send to it, serialize complete event writes with `Lock` or a single consumer
`Channel`.

Raku++ default execution may serialize Raku code, while
`RAKUPP_PARALLEL=1` permits real parallel execution. Make shared state and
response ordering correct in parallel mode.

Use bounded queues, coalescing, or latest-snapshot behavior for slow clients.
Never allow an unbounded `Channel` or array of pending renders per connection.

Use `Promise`, `Supply`, or `Channel` only where the verified server integration
benefits from them. First implement a correct serial request and one ordered
stream.

## Verification

Adapt to project commands, then run:

```sh
rakupp --check lib/Datastar.rakumod
rakupp --lint lib/Datastar.rakumod
rakupp -I lib t/datastar-protocol.raku
RAKUPP_PARALLEL=1 rakupp -I lib t/datastar-stream.raku
```

Also:

- Compare encoded output byte-for-byte with representative
  `sdk/tests/golden/` fixtures.
- Run the official/local SDK conformance runner against a disposable server.
- Exercise GET and POST signal decoding.
- Exercise multiline payloads and multiple ordered events.
- Close a client mid-stream and confirm producer cancellation.
- Run through the real proxy with compression and buffering configuration.
- Compile and run a native executable when deployment uses `rakupp --exe`.

Report any HTTP, module, JSON, or concurrency path not exercised under the
active Raku++ runtime.
