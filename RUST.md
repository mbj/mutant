# Mutant Rust

## Overview

Large parts of Mutant are being replaced with Rust for better performance and
developer ergonomics. Rust's advanced type system (ADTs) offers a much higher
complexity ceiling without driving the author insane.

## Current State

By default, mutant runs entirely in Ruby. The Rust implementation is opt-in
and currently wraps the Ruby CLI, delegating all commands to the Ruby
implementation. This allows incremental migration while maintaining full
compatibility. A Ruby interpreter is still required to run mutant.

## Planned Migration

Ruby-independent logic will be incrementally moved to Rust:

- Process management
- IPC (inter-process communication)
- Result aggregation
- Rendering

## Future Features

Rust will enable features that are difficult to implement in Ruby:

- Distributed mutation testing
- Advanced tracing

## FAQ (Shitstorm Prevention)

**Q: Why not rewrite in $LANGUAGE?**

A: The author has extensive experience with Rust and finds it productive for this
use case. This is a pragmatic choice, not advocacy.

**Q: Rust is overhyped.**

A: Agreed. But hype doesn't make a tool useless. Rust solves real problems here:
expressing complex state machines and catching bugs at compile time that would
otherwise surface in production. Other languages can
solve these too, but Rust is the most pragmatic choice due to the intersection
of type system, ecosystem, static binary support, and easy targeting of multiple
CPU architectures.

**Q: Ruby is fast enough.**

A: No. The author has extensive experience using Ruby in high concurrency and
complexity environments (a main reason Mutant exists). For many Mutant users,
Ruby is not even fast enough to aggregate results quickly. Mutation testing is
CPU and IPC latency bound. Just because you haven't hit Ruby's limitations
doesn't mean they don't exist.

**Q: You're abandoning Ruby.**

A: No, mitigating it. Mutant itself is a Ruby mitigation technique among many.
Ruby remains excellent for mutation operators and AST manipulation. The goal
is to use each language where it excels.

**Q: But Ruby has a type system too.**

A: Mutant's Ruby implementation, while complex, is not (yet) and hopefully never
will be a black hole with enough gravity to need an incremental change to Sorbet.
I can maximize value by moving to a first-class type system, not an (however
awesome given the starting point) backfill.

**Q: This adds complexity.**

A: Yes. The tradeoff is worth it for the author. Your mileage may vary.

## Running Mutant

```bash
bundle exec mutant run
```

The `bin/mutant` dispatcher selects between `bin/mutant-ruby` and `bin/mutant-rust`
based on the `MUTANT_RUST` environment variable.

### Environment Variables

- `MUTANT_RUST`: Set to `1` to use the Rust implementation (default: Ruby)

## Version Management

The single source of truth for the version is `Cargo.toml` at the workspace root
using workspace version inheritance. Both `mutant` and `manager` crates inherit
this version.

The Ruby implementation reads the version differently depending on how it's invoked:
- With `MUTANT_RUST=1`: reads from `MUTANT_VERSION` environment variable
- Without `MUTANT_RUST`: reads from `ruby/VERSION` file

See `ruby/lib/mutant/version.rb` for implementation details.
