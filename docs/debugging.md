# Debugging and Utilities

Mutant provides several commands to help debug configuration issues, inspect the environment, and understand mutations.

## Environment Inspection Commands

These commands help verify that mutant is loading and configuring the environment correctly without running full mutation analysis.

### `mutant environment show`

Display the mutant environment configuration without running coverage analysis.

```sh
bundle exec mutant environment show
```

This command:
- Loads the mutant configuration
- Sets up the environment and integration
- Displays the environment summary (similar to what appears at the start of `mutant run`)
- Exits without performing mutation testing

**Use cases:**
- Verify configuration is loading correctly
- Check that subjects are being matched as expected
- Confirm integration is properly configured
- Debug environment setup issues before running tests

**Example output:**
```
Mutant environment:
Usage:           opensource
Integration:     Mutant::Integration::Rspec
Jobs:            8
Includes:        ["lib"]
Requires:        ["my_app"]
Subjects:        42
```

### `mutant environment subject list`

List all subjects that match the configured expressions without running mutations.

```sh
bundle exec mutant environment subject list
```

This command:
- Loads the mutant environment
- Resolves all subject expressions
- Lists each matched subject with its full expression syntax
- Does not generate or run any mutations

**Use cases:**
- Verify subject expressions are matching the intended code
- Debug why certain classes or methods are not being mutated
- Understand which subjects will be tested before running mutation analysis
- Check the scope of a matcher expression

**Example output:**
```
Subjects in environment: 42
MyApp::UserService#create
MyApp::UserService#update
MyApp::UserService#delete
MyApp::OrderProcessor#process
...
```

**Filtering subjects:**

Use subject expressions on the command line to see what they match:

```sh
# See all subjects in a namespace
bundle exec mutant environment subject list MyApp::UserService*

# See subjects for a specific class
bundle exec mutant environment subject list MyApp::UserService

# See all instance methods on a class
bundle exec mutant environment subject list MyApp::UserService#

# See subjects changed since a git reference
bundle exec mutant environment subject list --since main
```

### `mutant environment irb`

Open an IRB session with the mutant environment fully loaded.

```sh
bundle exec mutant environment irb
```

This command:
- Loads the mutant configuration
- Sets up the environment (requires, includes, environment variables)
- Starts an interactive IRB session at the top level
- Provides access to all loaded code for inspection

**Use cases:**
- Debug loading issues interactively
- Inspect constants and classes after mutant environment setup
- Test code snippets in the mutant environment
- Verify that requires and includes are working correctly

**Example session:**
```ruby
bundle exec mutant environment irb
irb(main):001:0> MyApp::UserService
=> MyApp::UserService
irb(main):002:0> MyApp::UserService.instance_methods(false)
=> [:create, :update, :delete]
```

## Mutation Inspection

### `mutant util mutation`

Print all mutations that would be generated for a code snippet without running tests.

```sh
# Mutate code from a file
bundle exec mutant util mutation path/to/file.rb

# Mutate inline code
bundle exec mutant util mutation -e 'def foo; true; end'

# Mutate with ignore patterns
bundle exec mutant util mutation -e 'def foo; logger.info("test"); true; end' -i 'send{selector=info}'
```

This command:
- Parses the provided Ruby code
- Generates all mutations
- Prints each mutation as a diff
- Does not require loading the application or running tests

**Use cases:**
- Understand what mutations mutant will generate for specific code
- Learn how mutant mutates different Ruby constructs
- Test ignore patterns before adding them to configuration
- Debug why certain mutations are or aren't being generated
- Educational purposes - see mutation testing in action

**Options:**

- `-e SOURCE` / `--evaluate SOURCE` - Mutate inline code (can be specified multiple times)
- `-i PATTERN` / `--ignore-pattern PATTERN` - Apply AST ignore pattern (can be specified multiple times)
- File arguments - Mutate code from files

**Example output:**

```sh
$ bundle exec mutant util mutation -e 'def foo; true; end'
<cli-source>
-def foo
-  true
-end
+def foo
+  false
+end
-def foo
-  true
-end
+def foo
+  nil
+end
-def foo
-  true
-end
+def foo
+end
```

**Testing ignore patterns:**

Use this command to verify ignore patterns work as expected:

```sh
# Without ignore pattern - mutates the log call
bundle exec mutant util mutation -e 'def process; log.info("Processing"); work; end'

# With ignore pattern - skips mutating the log call
bundle exec mutant util mutation -e 'def process; log.info("Processing"); work; end' -i 'send{selector=info}'
```

See the [AST Pattern documentation](/docs/ast-pattern.md) for details on pattern syntax.

## Debugging Workflows

### Verify Configuration Before Mutation Testing

Recommended workflow when setting up mutant or debugging issues:

```sh
# 1. Verify environment loads correctly
bundle exec mutant environment show

# 2. Check which subjects are matched
bundle exec mutant environment subject list

# 3. Verify tests work with mutant (if needed)
bundle exec mutant test run

# 4. Run mutation testing
bundle exec mutant run
```

### Debug Subject Matching Issues

If subjects are not being matched as expected:

```sh
# List all subjects to see what's being matched
bundle exec mutant environment subject list

# Try different expressions to narrow down the issue
bundle exec mutant environment subject list MyNamespace*
bundle exec mutant environment subject list MyNamespace::MyClass
bundle exec mutant environment subject list MyNamespace::MyClass#my_method

# Open IRB to inspect constants
bundle exec mutant environment irb
```

### Debug Loading Issues

If the application or tests are not loading correctly:

```sh
# Show environment to see if configuration is recognized
bundle exec mutant environment show

# Open IRB to test requires interactively
bundle exec mutant environment irb
irb(main):001:0> require 'my_app'
irb(main):002:0> MyApp
```

Check configuration:
- Verify `requires` in configuration file
- Verify `includes` paths are correct
- Check `environment_variables` are set appropriately (e.g., `RAILS_ENV: test`)

### Understand Generated Mutations

Before running full mutation testing, preview what mutations will be generated:

```sh
# Extract a method to a file
cat > /tmp/my_method.rb <<'EOF'
def calculate_total(items)
  items.sum(&:price) * 1.1
end
EOF

# See what mutations would be generated
bundle exec mutant util mutation /tmp/my_method.rb
```

### Test Mutation Ignore Patterns

When adding ignore patterns to configuration, test them first:

```sh
# Test pattern matches what you expect
bundle exec mutant util mutation -e 'log.debug("foo")' -i 'send{selector=debug}'

# Verify it doesn't ignore too much
bundle exec mutant util mutation -e 'log.debug("foo"); calculate()' -i 'send{selector=debug}'
```

## Command Line Options

### Common Options

All environment commands support the standard mutant configuration options:

```sh
# Use specific configuration file
bundle exec mutant environment show -c custom.yml

# Override integration
bundle exec mutant environment show --integration rspec

# Add requires
bundle exec mutant environment show --require my_app

# Add includes
bundle exec mutant environment show --include lib
```

## Troubleshooting Tips

### "No subjects found"

```sh
# Check what the configuration is matching
bundle exec mutant environment subject list

# Try broader expressions
bundle exec mutant environment subject list YourNamespace*

# Verify code is loaded
bundle exec mutant environment irb
```

### "Cannot load integration"

```sh
# Verify environment loads
bundle exec mutant environment show

# Check requires in configuration
# Ensure test framework gem is in Gemfile
```

### "Subjects matched but mutations fail"

```sh
# First verify tests work without mutations
bundle exec mutant test run

# Check a specific subject's mutations
bundle exec mutant util mutation -e 'def your_method; ...; end'
```

## See Also

- [Configuration](/docs/configuration.md) - Configuration file options
- [AST Pattern](/docs/ast-pattern.md) - Ignore pattern syntax
- [Test Runner](/docs/test-runner.md) - Running tests without mutations
- [Nomenclature](/docs/nomenclature.md) - Understanding mutant terminology
