# Go Datastar Backend

Use this reference for Datastar applications implemented in Go. Apply the
project's existing Go conventions and the installed `go-best-practices` skill
when available.

## Contents

- Prefer the official SDK
- Handler architecture
- Rendering and state
- Streaming and concurrency
- Testing

## Prefer the Official SDK

Use the official module unless the application pins another compatible path:

```sh
go get github.com/starfederation/datastar-go
```

Current official documentation uses:

```go
import "github.com/starfederation/datastar-go/datastar"
```

Verify the pinned module's API with `go doc` and its source before coding. Do
not copy method names from examples targeting another release.

The commonly documented flow is:

```go
var signals Signals
if err := datastar.ReadSignals(r, &signals); err != nil {
    http.Error(w, "invalid signals", http.StatusBadRequest)
    return
}

sse := datastar.NewSSE(w, r)
sse.PatchElements(renderPage(model))
```

Check the active methods' return contracts and handle errors where the pinned
SDK exposes them. Do not force signatures from another release to compile.

## Handler Architecture

Keep handlers as adapters:

```text
*http.Request
  -> typed signal/input data
  -> domain function
  -> result/model data
  -> template or renderer
  -> Datastar SSE writer
```

Use `context.Context` as the first parameter for domain operations that block,
perform I/O, or can be cancelled. Pass `r.Context()` through to persistence and
stream producers.

Keep domain state independent from `http.ResponseWriter`,
`*http.Request`, and Datastar SDK objects.

Prefer explicit data:

```go
type CreateItemInput struct {
    Name string `json:"name"`
}

type PageModel struct {
    Items   []Item
    Pending bool
    Error   string
}
```

Return concrete result types. Keep interfaces small and define them at the
consumer boundary only when substitution is required.

## Rendering and State

Use `html/template`, `templ`, or the project's existing server renderer. Escape
untrusted values. Render complete elements with stable IDs.

Let the backend own durable and shared state. Signals should primarily carry
form input, local interaction, and pending intent.

Prefer one coherent renderer over manual strings distributed through handlers.
Make renderer tests table-driven and assert meaningful DOM structure or stable
golden output.

Use `PatchElements` for authoritative rendered state. Use
`MarshalAndPatchSignals` or the pinned equivalent for small UI signal changes.
Do not send domain facts twice as both HTML and a duplicate client-side model
without a concrete need.

## Streaming and Concurrency

For long-lived streams:

- Exit on `<-r.Context().Done()`.
- Give each connection a bounded update mechanism.
- Coalesce events or send the latest authoritative snapshot to slow clients.
- Protect shared state with a mutex or confine it to one owning goroutine.
- Never hold a state mutex while writing to a client.
- Ensure only one goroutine writes a given SSE response, unless the pinned SDK
  explicitly guarantees ordered concurrent writes.
- Configure `http.Server` timeouts deliberately. Do not apply a write timeout
  that unintentionally kills valid long-lived streams.
- Stop tickers and unregister subscriptions with `defer`.

Prefer normal HTTP/2 multiplexing plus SSE and action requests. Add WebSockets
only for a measured full-duplex requirement.

Verify reverse-proxy buffering, compression, cancellation, and graceful
shutdown in the deployed topology.

## Testing

Use:

```sh
gofmt -w .
go test ./...
go test -race ./...
go vet ./...
```

Follow the project's build system when it differs.

Test handlers with `httptest`:

- Valid and malformed signal requests.
- GET query and write-method body decoding.
- Response status and SSE content type.
- Complete element patches with stable IDs.
- Multiple ordered events and multiline payloads.
- Context cancellation and client disconnect.
- Rejection after pending intent without false success.

When modifying an adapter rather than merely using the official SDK, run the
Datastar SDK conformance suite and compare against the active golden fixtures.

Pin dependencies through `go.mod`; do not embed a remembered Datastar version
in generated instructions. Report the module version used by verification.
