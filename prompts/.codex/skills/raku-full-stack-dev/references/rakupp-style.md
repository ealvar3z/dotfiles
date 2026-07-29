# Raku++ Data-Oriented Raku Style

Use this reference when designing, refactoring, or reviewing application code.
Apply it pragmatically: native data is the default, not a prohibition on useful
objects.

## Contents

- Data-first model
- Containers and sigils
- Transformations and dispatch
- Parsing into data
- Mutation and concurrency
- Appropriate objects
- Modules and naming
- Review checklist

## Data-First Model

Represent application facts in values that can be inspected, compared,
serialized, and transformed directly:

```raku
my %request = method => 'POST', path => '/notes', body => %payload;
my @notes   = %store<notes>.Array;
my %result  = ok => True, note => %note;
```

Prefer a visible data pipeline:

```raku
sub validate-note(%input --> Hash) { ... }
sub create-note(%valid, %state is rw --> Hash) { ... }
sub render-result(%result --> Str) { ... }
```

Return data describing expected outcomes. Reserve exceptions for exceptional or
non-local control flow rather than using them as ordinary result branches.

Do not split a cohesive transformation across controller, service, repository,
entity, and mapper objects without a concrete behavioral reason.

## Containers and Sigils

Use sigils to communicate shape:

- `$value` holds one item, even when that item is an array or hash.
- `@values` presents mutable positional storage.
- `%values` presents mutable associative storage.
- `&operation` presents callable behavior.

Preserve the distinction between `List` and `Array`. Treat lists as immutable
sequences and arrays as mutable containers. Convert deliberately with `.List`
or `.Array` when the contract requires a particular shape.

Account for Raku itemization and flattening:

- Parenthesized and list-producing expressions may flatten in list context.
- An array held in a scalar stays one item.
- `Slip` intentionally spreads into its surrounding list.
- Assignment with `=` copies values into a container according to assignment
  semantics; binding with `:=` aliases a container or value.

Make aliases rare and explicit. Use `:=` only when shared identity is required
and document the owner of the bound state.

Use `Pair`s for named facts and construction, hashes for records or indexes, and
arrays for ordered collections. Avoid positional arrays as unnamed records when
the element meaning is not obvious.

## Transformations and Dispatch

Prefer small routines with useful signatures:

```raku
sub normalize-user(%raw --> Hash) {
    %( name => %raw<name>.trim, email => %raw<email>.lc )
}

multi sub encode-value(Str $value --> Str) { ... }
multi sub encode-value(Associative $value --> Str) { ... }
multi sub encode-value(Positional $value --> Str) { ... }
```

Use:

- `map`, `grep`, `classify`, `categorize`, `reduce`, and `sort` when they express
  the data transformation more directly than index mutation.
- `given`/`when` for a finite command or protocol dispatcher.
- `multi` for behavior selected naturally by Raku's type and signature
  dispatch.
- Explicit loops when mutation, early exit, or stateful scanning is the clearer
  algorithm.

Do not force a point-free or chained style when named intermediate values make
the data shapes clearer. Do not hide side effects inside `map` or `grep`.

Use typed parameters and return constraints when they clarify the boundary and
the active Raku++ build supports the exact form. Do not build a nominal class
hierarchy solely to obtain type names for record-shaped data.

## Parse Into Native Data

Use a grammar and actions for structured or recursive text:

```raku
grammar Config {
    rule TOP  { <pair>* }
    rule pair { <key> '=' <value> }
    token key { <[A..Za..z_]> \w* }
    token value { \N* }
}

class ConfigActions {
    method TOP($/)  { make $<pair>.map(*.made).hash }
    method pair($/) { make ~$<key> => ~$<value> }
}
```

Make the parse result a hash, array, pair, scalar, or a small tree of those
values. Perform validation and domain work after parsing. Keep `Match` objects
and grammar-specific state out of the domain core.

Use a hand scanner when the problem depends on simple stateful lookbehind,
indent tracking, or token preprocessing that a grammar would obscure. Raku++
showcases deliberately combine preprocessors with grammars where that division
is clearer.

## Mutation and Concurrency

Keep one clear owner for mutable state. Prefer routines that compute new result
data, then update the owned state in a small, obvious section.

Avoid mutable package globals for domain state. When process-wide state is
appropriate, keep it near the entrypoint or inside an explicit runtime state
value passed to handlers.

Guard shared mutable state:

```raku
my $lock = Lock.new;
my %store;

sub put(Str $key, $value) {
    $lock.protect: { %store{$key} = $value }
}
```

Default Raku++ execution serializes Raku code with a global interpreter lock,
but `RAKUPP_PARALLEL=1` permits true parallel execution. Write shared-state code
correctly for parallel mode rather than depending on default serialization.

Use:

- `start` and `Promise` for owned units of asynchronous work.
- `Channel` for an explicit thread-safe queue.
- `Supply` and `Supplier` for event streams.
- `Lock` for shared mutation that cannot be eliminated.

Do not share a mutable hash or array across workers without synchronization.
Do not add concurrency to pure transformations unless measurement or latency
requirements justify it.

## Appropriate Objects

Use a class when at least one of these is true:

- The value has identity and a lifecycle.
- Methods protect an invariant around private mutable state.
- A resource such as a connection has behavior tied to its state.
- A grammar actions object or callback protocol requires methods.
- A unique sentinel needs a distinct type.
- An exception carries structured failure information.

Use a role when several real types share a behavioral contract or reusable
implementation. Prefer composition over deep inheritance.

Avoid:

- A class containing only public attributes with trivial accessors.
- A service class containing stateless methods that could be module routines.
- A repository object that only forwards to one persistence function.
- A class per JSON object or database row without behavioral invariants.
- A hierarchy used only to emulate tagged data that `multi` or `given` handles
  directly.

## Modules and Naming

Put reusable behavior in `.rakumod` files under `lib/`. Use `unit module` and
export only the intended interface:

```raku
unit module Notes::Domain;

sub create-note(%input, %state is rw --> Hash) is export { ... }
```

Keep adapters separate from domain transformations when the separation produces
independently testable code. Do not create one-file-per-routine ceremony.

Prefer descriptive kebab-case routine names and meaningful data keys. Follow an
existing codebase's established naming when it is consistent.

Use `MAIN` for CLI argument handling. Convert CLI values into canonical data,
call domain routines, then format the result. Keep `%*ENV`, `$*IN`, `$*OUT`,
filesystem access, and process execution out of domain routines.

## Review Checklist

- Can the main behavior be read as a flow of data?
- Are record and collection shapes visible through names and sigils?
- Are parsing, I/O, persistence, and presentation confined to boundaries?
- Can domain transformations run without external resources?
- Is mutation local, owned, and synchronized when shared?
- Does each class or role have a behavioral reason to exist?
- Are itemization, flattening, copying, and binding intentional?
- Are errors explicit data or intentional exceptions rather than silent
  fallbacks?
- Does every used language feature and module execute under the active
  `rakupp`?
