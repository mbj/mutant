# Quick Start Example

This is a working example demonstrating mutation testing with mutant.

This example is referenced in the main [README](../README.md).

## Setup

```bash
bundle install
```

## Run the tests

```bash
bundle exec rspec
```

Tests pass:

```
2 examples, 0 failures
```

## Run mutant

```bash
bundle exec mutant run --use rspec --usage opensource --require ./lib/person 'Person#adult?'
```

Mutant finds surviving mutations:

```
@@ -1,3 +1,3 @@
 def adult?
-  @age >= 18
+  @age > 18
 end
```

The tests don't cover `age == 18`, so changing `>=` to `>` doesn't break them.

## Fix it

Add a test for the boundary case in `spec/person_spec.rb`:

```ruby
it 'returns true for age 18' do
  expect(Person.new(age: 18).adult?).to be(true)
end
```

Run mutant again - 100% coverage.

## Compare coverage tools

Run the comparison script to see the difference between line coverage, branch coverage,
and mutation coverage:

```bash
./compare_coverage
```

This runs:

1. **SimpleCov** (line coverage) - reports 100% because the line was executed
2. **DeepCover** (branch coverage) - reports 100% because both true/false branches were taken
3. **Mutant** (mutation coverage) - reports ~88% because mutations survive

Only mutation coverage catches that the boundary condition `age == 18` is untested.

## Note on mutation operators

This example demonstrates a simple operator replacement (`>=` to `>`). Mutant supports
many more mutation operators including:

- Arithmetic operators (`+`, `-`, `*`, `/`)
- Logical operators (`&&`, `||`)
- Comparison operators (`==`, `!=`, `<`, `>`, `<=`, `>=`)
- Bitwise operators (`&`, `|`, `^`)
- Statement removal
- Boolean literal replacement
- Return value modification
- And many more...

See the [meta](../ruby/meta) directory for the full list of supported mutations.
