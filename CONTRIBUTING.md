# Contributing to Mutant

## Contributor License Agreement

Mutant is a commercial product. Before contributing, you must sign a Contributor License Agreement (CLA).

Contact [mbj@schirp-dso.com](mailto:mbj@schirp-dso.com?subject=Mutant%20CLA) for details.

## Getting Started

1. Fork and clone the repository
2. Run `./bin/manager ruby prepare` to set up the Ruby environment
3. Run `bundle install` in the `ruby/` directory
4. Run tests with `./bin/manager ruby rspec unit`

## CI Test Matrix

Mutant is tested on CI across the following dimensions:

* Ruby versions: 3.2, 3.3, 3.4, 4.0
* Targets:
  * aarch64-apple-darwin
  * aarch64-unknown-linux-gnu
  * aarch64-unknown-linux-musl
  * x86_64-unknown-linux-gnu
  * x86_64-unknown-linux-musl
* Test suites:
  * rspec spec-unit: Unit tests for mutant internals
  * mutant test: Verify mutant can run its own test suite
  * mutant run: Incremental mutation coverage on changed code
  * quick-start-verify: Verify the quick_start example works
  * rspec integration-misc: Integration tests for isolation and parallelism
  * rspec integration-minitest: Integration tests for minitest support
  * rspec integration-rspec: Integration tests for rspec support
  * rspec integration-generation: Tests for mutation generation
  * rubocop: Style and lint checks

This results in 180 test jobs per commit (4 Ruby versions x 5 targets x 9 test suites).

## Running Tests Locally

```bash
# Unit tests
./bin/manager ruby rspec unit

# Integration tests
./bin/manager ruby rspec integration

# Rubocop
./bin/manager ruby rubocop

# Mutation testing on changed code
./bin/manager ruby mutant run -- --since HEAD~1
```

## Adding New Mutations

When contributing new mutation operators, there are important design principles to follow.

### Mutation Direction Rules

Mutant deliberately avoids creating *unjustified* circular mutation pairs. Many mutation engines get this wrong by including mutations that can cycle back and forth indefinitely without reason. Mutant's design ensures a key invariant: **if you accept a surviving mutation by editing your code to match it, the mutation dies.** If Mutant included unjustified circular mutations, this invariant would break: you'd accept a mutation, and Mutant would immediately propose mutating back to the original code.

Mutant can only *replace* semantics with orthogonal behavior or *reduce* semantics, not *add* semantics.

A helpful mental model is to think of a "semantic truth table" for the operator:

| Mutation Type | Description | Allowed? |
|---------------|-------------|----------|
| **Orthogonal replacement** | Replaces cell values in the truth table, but dimensions stay the same | ✅ Yes |
| **Semantic reduction** | Removes a column or row from the truth table | ✅ Yes |
| **Semantic expansion** | Adds a column or row to the truth table | ❌ No |

#### Example: Valid mutation (`a || b` → `a && b`)

Both operators have the same truth table dimensions (2×2), but different cell values:

| `a` | `b` | `a \|\| b` | `a && b` |
|-----|-----|------------|----------|
| T   | T   | T          | T        |
| T   | F   | T          | F        |
| F   | T   | T          | F        |
| F   | F   | F          | F        |

This is an **orthogonal replacement** — the structure is identical, only values change.

#### Example: Invalid mutation (`a < b` → `a <= b`)

The operator `<=` is logically equivalent to `a < b || a == b`. This *adds* semantics for the `a == b` case:

| Comparison | `a < b` | `a == b` | `a > b` |
|------------|---------|----------|---------|
| `a < b`    | T       | F        | F       |
| `a <= b`   | T       | **T**    | F       |

The `a == b` column changes from `F` to `T` — this is a **semantic expansion** (adding behavior).

The reverse direction (`a <= b` → `a < b`) is valid because it *removes* that behavior (semantic reduction).

#### Orthogonal replacements must be circular

Orthogonal replacements are inherently bidirectional — if `a` → `b` is valid as an orthogonal replacement, then `b` → `a` must also be valid, because swapping truth table cell values works in both directions. If you can only justify mutating in one direction, it is not an orthogonal replacement; it is either a semantic reduction (one direction removes behavior) or the mutation should not be included at all.

As a rule of thumb, the circular mutation is worth including when it flips at least 25% of the truth table cells.

**Example — Acceptable circular mutation:** `a + b` ↔ `a - b`

These operators change behavior for roughly half of all input combinations. Any test suite exercising basic arithmetic will easily detect the difference. Mutant mutates in both directions because the semantic change is large and observable.

**Example — Unacceptable circular mutation:** `(a..)` ↔ `(a...)`

The difference between inclusive and exclusive endless ranges is only observable through reflection (e.g., `range.exclude_end?`), not through actual runtime behavior when iterating or checking membership. This makes the mutation nearly impossible to detect through normal tests. Even though this is an orthogonal replacement (the truth table dimensions stay the same), the change affects too little observable behavior to justify circular mutation.

Note: A contribution adding a mutation in one direction (e.g., `a...` → `a..`) would be acceptable.

### No Class-Level Mutations

Mutant does not support mutation subjects at the class level (e.g., mutating class definitions, inheritance, or module includes). These would require "boot-time mutations" -- trapping processes during loading, applying mutations, then releasing forked processes to carry the mutation forward through the entire application load.

This is complex to implement correctly, especially with Ruby's autoloaders, and adds significant maintenance burden. The upcoming Rust implementation of Mutant may revisit this limitation.

## Communication

* [GitHub Issues](https://github.com/mbj/mutant/issues)
