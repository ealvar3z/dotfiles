# Raku++ Full-Stack Patterns

Use this reference when an application crosses CLI, file, network, storage,
process, or browser boundaries. Adapt the layout to the existing repository;
the data flow matters more than a prescribed directory tree.

## Contents

- Core architecture
- CLI and modules
- HTTP and TCP services
- Persistence
- Browser and Raku.js
- Concurrency
- Error handling
- Verification matrix

## Core Architecture

Organize each vertical slice around four responsibilities:

1. Decode an external representation.
2. Convert it to canonical native Raku data.
3. Transform that data with domain routines.
4. Encode the result or perform an explicit side effect.

Keep boundary contracts small:

```raku
sub parse-request(Str $wire --> Hash) { ... }
sub dispatch(%request, %state is rw --> Hash) { ... }
sub render-response(%response --> Str) { ... }
```

Use result records with stable keys for expected outcomes:

```raku
%( status => 200, headers => %headers, body => $body )
%( status => 404, error => 'note-not-found' )
```

Keep framework-specific or transport-specific objects inside their adapter. Do
not pass them through the domain layer.

## CLI and Modules

Use `MAIN` as an adapter:

```raku
sub MAIN(Str $file, Bool :$compact = False) {
    my %input = read-input($file);
    my %result = transform(%input);
    say encode-output(%result, :$compact);
}
```

Use project modules from `lib/` and verify the actual load path with `rakupp -I
lib` or the repository's existing command. Export the smallest useful set of
routines.

Treat required dependency loading as a startup check. Raku++ can warn and
continue after a failed `use`, unlike Rakudo's normal fatal behavior. Exercise a
known symbol or capability before accepting traffic or modifying data.

Do not assume a zef module is compatible merely because it is installed. Run
the exact code path under Raku++.

## HTTP and TCP Services

Build protocol handling as a sequence:

```text
socket bytes
  -> request frame
  -> request data
  -> route or command dispatch
  -> response data
  -> encoded response
  -> socket write
```

Keep request parsing, routing, domain behavior, HTML rendering, and response
encoding in separate routines when they can be tested independently.

For HTTP:

- Parse the request line, headers, and body at the boundary.
- Represent requests and responses as hashes.
- Validate method, path, content length, and content type explicitly.
- Escape untrusted data for its output context.
- Set byte-accurate content lengths after encoding.
- Make unsupported methods and malformed requests explicit responses.
- Add graceful shutdown and resource cleanup for deployable services.

For custom TCP protocols:

- Define framing and maximum input size.
- Convert each complete frame to command data.
- Dispatch with `given`/`when` or a verified callable table.
- Return response data before encoding it.
- Keep one connection's transient state separate from shared application state.

Start with the simplest Raku++ socket API proven by the active repository.
Choose synchronous or async I/O based on measured needs and supported behavior,
not fashion.

## Persistence

Define persistence as functions over data:

```raku
sub load-note($db, Str $id --> Hash) { ... }
sub save-note($db, %note --> Hash) { ... }
```

Keep database rows, command output, and filesystem formats inside the adapter.
Translate them into the same canonical data used by in-memory tests.

Make transaction and ownership boundaries explicit. Do not spread database
calls through rendering and protocol code.

Verify the exact persistence route:

- Confirm the required module loads under Raku++.
- Confirm connection or subprocess startup.
- Execute a read and a write against a disposable target.
- Test empty results and failures.
- Avoid treating a warning followed by continued execution as success.

Use an in-memory hash only when persistence is not required or when it is an
intentional test adapter. Do not present it as durable storage.

## Browser and Raku.js

Use Raku.js for Raku parsing, transformation, validation, or domain behavior in
the browser. Keep the web shell responsible for DOM events, rendering, and
browser APIs:

```text
DOM event
  -> thin JavaScript bridge
  -> serialized input
  -> Raku.js program
  -> serialized output
  -> DOM update
```

Reuse the same pure Raku module or source for native and browser execution when
the behavior lies inside the supported common surface. Keep environment-specific
adapters outside that module.

Account for browser constraints:

- No server sockets.
- No native worker-thread model exposed as ordinary Raku threads.
- Shallower recursion than native execution.
- Potential startup cost for the WebAssembly module.
- Explicit transfer of text or data across the JavaScript boundary.

Keep recursive algorithms shallow or iterative for browser-facing code. Test in
the real browser artifact, not only through native `rakupp`.

Do not move ordinary DOM manipulation into generated Raku source merely to claim
an all-Raku frontend. Prefer a small, legible JavaScript host and keep valuable
domain logic in Raku.

## Concurrency

First implement a correct serial handler. Add concurrency around owned work:

- One task per independent connection or job.
- A `Channel` for explicit work or result queues.
- A `Supply` for event streams.
- A `Lock` around unavoidable shared mutation.

Default Raku++ mode overlaps blocking waits while serializing Raku execution.
Use `RAKUPP_PARALLEL=1` only for verified CPU-bound benefits. Test both modes
when application correctness depends on shared state.

Do not hold locks across socket, database, filesystem, subprocess, or `await`
operations. Copy the necessary data under the lock, release it, then perform the
slow operation.

## Error Handling

Classify failures at the boundary:

- Malformed external input becomes a structured client error.
- Missing domain data becomes an explicit result such as
  `%(ok => False, error => 'not-found')`.
- Required dependency failure aborts startup with a clear message.
- Unexpected internal failure becomes a logged server error without leaking
  sensitive details.
- Broken Promises are inspected or awaited intentionally; do not silently drop
  their causes.

Use typed exceptions when non-local control flow or integration APIs make them
the clearer mechanism. Convert exceptions to result or response data at the
outer boundary.

## Verification Matrix

Verify only the surfaces used, but cover each used surface end to end:

| Surface | Minimum verification |
|---|---|
| Domain | Table-driven inputs and expected native data |
| Parser | Valid, malformed, empty, Unicode, and oversized input |
| CLI | Arguments, stdin or file input, exit status, stdout and stderr |
| Module | Load and invoke an exported symbol under `rakupp` |
| HTTP/TCP | Real local connection, success, malformed request, shutdown |
| Persistence | Disposable read/write round trip and failure path |
| Concurrency | Shared-state test in default and parallel modes |
| Native build | Compile with `--exe` and run the produced binary |
| Raku.js | Build or bundle and exercise in the browser artifact |
| Parity | Compare observable output with Rakudo only when required |

Run `--check` and `--lint`, but do not confuse static success with a working
module, network path, persistence route, native executable, or browser bundle.
