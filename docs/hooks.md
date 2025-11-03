# Hooks

Mutant provides a hooks system that allows to inject custom behavior at critical points in the mutation testing execution pipeline. This is useful for setting up worker-specific resources, instrumenting mutations, or customizing the testing environment.

## Available Hooks

Mutant provides 8 different hook types that fire at various stages of execution:

### Environment Hooks

- **`env_infection_pre`** - Runs before environment infection (loading requires/includes)
  - Payload: `env:` (the `Mutant::Env` object)
- **`env_infection_post`** - Runs after environment infection
  - Payload: `env:` (the `Mutant::Env` object)

### Integration Setup Hooks

- **`setup_integration_pre`** - Runs before test integration setup
  - Payload: None
- **`setup_integration_post`** - Runs after test integration setup
  - Payload: None

### Mutation Hooks

- **`mutation_insert_pre`** - Runs before a mutation is inserted into the code
  - Payload: `mutation:` (the `Mutant::Mutation` object)
- **`mutation_insert_post`** - Runs after a mutation is inserted
  - Payload: `mutation:` (the `Mutant::Mutation` object)

### Worker Process Hooks

- **`mutation_worker_process_start`** - Runs when a mutation worker process starts
  - Payload: `index:` (the worker process index number)
- **`test_worker_process_start`** - Runs when a test worker process starts
  - Payload: `index:` (the worker process index number)

## Configuration

Hooks are configured in your mutant configuration file (`.mutant.yml`, `config/mutant.yml`, or `mutant.yml`) by specifying paths to hook files:

```yml
---
hooks:
  - path/to/hooks_file_1.rb
  - path/to/hooks_file_2.rb
```

## Hook File Format

Hook files are Ruby files that register hooks using the `hooks.register` method. Each hook receives a block that will be executed when the hook fires:

```ruby
# Example: Log when mutations are inserted
hooks.register(:mutation_insert_pre) do |mutation:|
  puts "About to insert mutation: #{mutation.identification}"
end

hooks.register(:mutation_insert_post) do |mutation:|
  puts "Inserted mutation: #{mutation.identification}"
end
```

## Common Use Cases

### Rails Application with Database Isolation

One of the most common use cases is setting up separate database resources for each worker process to avoid conflicts during parallel execution. Here's a complete example for Rails applications using PostgreSQL:

```ruby
# rails_hooks.rb
hooks.register(:env_infection_post) do
  Rails.application.eager_load!
end

hooks.register(:setup_integration_post) do
  base_records.each do |base|
    disconnect_pool(base:)
  end
end

hooks.register(:test_worker_process_start) { |index:| isolate_index(index:) }
hooks.register(:mutation_worker_process_start) { |index:| isolate_index(index:) }

def self.base_records
  [
    ActiveRecord::Base,
  ]
end

def self.isolate_index(index:)
  base_records.each do |base|
    disconnect_pool(base:)
    isolate_database(base:, index:)
  end
end

def self.isolate_database(base:, index:)
  db_config = base
    .connection_handler
    .retrieve_connection_pool(base.connection_specification_name)
    .db_config

  raw_template_database = db_config.database
  raw_isolated_database = "#{raw_template_database}_mutant_worker_#{index}"

  with_root_connection do |connection|
    template_database = PG::Connection.quote_ident(raw_template_database)
    isolated_database = PG::Connection.quote_ident(raw_isolated_database)

    connection.exec_query("DROP DATABASE IF EXISTS #{isolated_database}")
    connection.exec_query("CREATE DATABASE #{isolated_database} TEMPLATE #{template_database}")
  end

  db_config._database = raw_isolated_database
end

def self.disconnect_pool(base:)
  base
    .connection_handler
    .retrieve_connection_pool(base.connection_specification_name)
    .disconnect
end

def self.with_root_connection
  base = ActiveRecord::Base

  pool = base
    .connection_handler
    .retrieve_connection_pool(base.connection_specification_name)

  connection = base
    .postgresql_connection(**pool.db_config.configuration_hash, database: 'postgres')

  yield connection

  connection.disconnect!
end
```

This example:
- Eager loads the Rails application after environment infection
- Disconnects database pools after integration setup
- Creates isolated PostgreSQL databases for each worker using the test database as a template
- Ensures parallel workers don't conflict with each other's database operations
- Note: This database isolation pattern also enables parallel test runs without mutation testing

### Mutation Instrumentation

You can instrument mutations for logging, tracing, or debugging:

```ruby
hooks.register(:mutation_insert_pre) do |mutation:|
  # Log mutation details to a file
  File.open('mutation_log.txt', 'a') do |f|
    f.puts "#{Time.now}: Testing #{mutation.identification}"
  end
end
```

### Custom Test Environment Setup

Use integration hooks to configure your test environment:

```ruby
hooks.register(:setup_integration_pre) do
  # Perform custom setup before test framework is initialized
  load_custom_helpers
  configure_test_environment
end

hooks.register(:setup_integration_post) do
  # Verify test framework is properly configured
  validate_test_configuration
end
```

### Environment Infection Customization

Customize how your application loads:

```ruby
hooks.register(:env_infection_pre) do |env:|
  # Set up special loading requirements
  require 'custom_loader'
end

hooks.register(:env_infection_post) do |env:|
  # Verify environment is properly loaded
  validate_application_state
end
```

## Hook Execution Order

When multiple hooks are registered for the same event:

1. Hooks from files are loaded in the order specified in the configuration
2. Within each file, hooks are registered in the order they appear
3. All hooks for an event execute sequentially in registration order

Example:

```ruby
# In first_hooks.rb
hooks.register(:mutation_insert_pre) do |mutation:|
  puts "First hook"
end

# In second_hooks.rb
hooks.register(:mutation_insert_pre) do |mutation:|
  puts "Second hook"
end
```

With configuration:
```yml
hooks:
  - first_hooks.rb
  - second_hooks.rb
```

Output when mutation is inserted:
```
First hook
Second hook
```

## Implementation Details

- Hooks are implemented in `lib/mutant/hooks.rb`
- The `Mutant::Hooks::Builder` class is used during hook file evaluation
- All hook data structures are immutable (frozen) after creation
- Hook files are evaluated using `binding.eval()` with the builder as context
- Unknown hook names raise `Mutant::Hooks::UnknownHook` error

## Error Handling

Specifying an invalid hook name will raise an error:

```ruby
hooks.register(:invalid_hook_name) do
  # This will raise: Mutant::Hooks::UnknownHook: Unknown hook :invalid_hook_name
end
```

Valid hook names are limited to the 8 hooks listed at the top of this document.

## Notes

- Hook blocks should be idempotent when possible
- Avoid long-running operations in hooks as they will slow down mutation testing
- Worker process hooks run in isolated child processes
- Environment and integration hooks run in the main process
- Mutation hooks run for each mutation being tested
