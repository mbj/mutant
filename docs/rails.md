# Rails Integration

Rails applications have specific requirements when running under mutant: the application must be initialized in test mode, all subjects must be loaded eagerly so they are discoverable, and parallel workers need isolated database resources to avoid conflicts.

This document is the canonical reference for setting up mutant against a Rails application. The mechanisms it relies on are documented in:

- [Configuration](/docs/configuration.md) — the configuration file format
- [Hooks](/docs/hooks.md) — the hooks system used for eager loading and resource isolation
- [Test Runner](/docs/test-runner.md) — parallel execution and resource isolation
- [RSpec Integration](/docs/mutant-rspec.md) / [Minitest Integration](/docs/mutant-minitest.md) — test framework integrations

## Minimal Setup

A working Rails configuration needs three things in `.mutant.yml`:

```yml
---
requires:
  - ./config/environment

environment_variables:
  RAILS_ENV: test

integration:
  name: rspec   # or minitest

hooks:
  - rails_hooks.rb
```

- `requires: ./config/environment` loads the Rails application.
- `RAILS_ENV: test` is set before the application loads, so initializers see the correct environment. See [`environment_variables`](/docs/configuration.md#environment_variables).
- `hooks:` is where Rails-specific behavior (eager loading, database isolation) is wired in.

The same configuration can be expressed on the CLI:

```sh
RAILS_ENV=test bundle exec mutant run -r ./config/environment --integration rspec User
```

## Recommended Hook: Eager Load

Rails relies on autoloading: a constant is only loaded the first time it is referenced. Mutant needs all subjects to be present in memory before subject discovery runs — otherwise classes that have not been touched will be invisible to the matcher.

The fix is to eager-load the application after mutant has infected the environment:

```ruby
# rails_hooks.rb
hooks.register(:env_infection_post) do
  Rails.application.eager_load!
end
```

This is the recommended baseline for any Rails project, even when no other hooks are needed. Without it, subject expressions can silently match nothing.

See the [hooks reference](/docs/hooks.md#available-hooks) for the full list of hook events.

## Database Isolation for Parallel Workers (PostgreSQL)

> **PostgreSQL-specific.** The example below uses `PG::Connection`, ActiveRecord's `postgresql_connection`, and the `CREATE DATABASE ... TEMPLATE` clause. The hook structure is portable to other adapters (see [Other Databases](#other-databases) below), but the code as written will not run against MySQL, SQLite, or other engines.

When running with multiple workers (the default), each worker shares the same Rails process layout and therefore the same database configuration. Without isolation, workers fight over the same tables and tests become non-deterministic.

The pattern below creates a per-worker copy of the test database using PostgreSQL's `TEMPLATE` clause. Each worker gets its own database (`<test_db>_mutant_worker_<index>`) cloned from the template at process start.

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

hooks.register(:test_worker_process_start)     { |index:| isolate_index(index:) }
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

What this does:

The actual per-worker database setup happens in the *worker-start* hooks. The other two hooks set up preconditions in the parent process.

- **`mutation_worker_process_start`** and **`test_worker_process_start`** — the core of the example. Both registered to the same `isolate_index` body. Each fires once inside a forked worker process: the worker drops the inherited connection, runs `CREATE DATABASE … TEMPLATE`, and rebinds `db_config._database` to the per-worker name. The two hooks fire under different commands — `mutation_worker_process_start` under `mutant run`, `test_worker_process_start` under `mutant test` — so **both registrations are required** if you want isolation in both modes. Drop one and that command's workers will trample each other on the shared template database.
- **`setup_integration_post`** — releases the parent's connection to the template database so workers *can* use it as a `TEMPLATE`. PostgreSQL refuses `CREATE DATABASE … TEMPLATE myapp_test` while any session (including the parent's RSpec/Minitest connection opened during integration setup) is connected to `myapp_test`. Without this hook the first worker's `CREATE DATABASE` errors with `source database "myapp_test" is being accessed by other users`. Fires in both `mutant run` and `mutant test`.
- **`env_infection_post`** — eager-loads the application so subjects are discoverable (see [Recommended Hook: Eager Load](#recommended-hook-eager-load) above). Fires in both `mutant run` and `mutant test`.

The `mutant test` case is worth calling out explicitly: this same hook file lets you run `mutant test` as a drop-in parallel test runner (no mutations), with the same per-worker database isolation — provided you registered `test_worker_process_start`. See [Test Runner](/docs/test-runner.md) for that workflow.

## Database Isolation for Parallel Workers (SQLite)

> **SQLite-specific.** SQLite database files should not be shared by parallel workers. The example below uses a test database file prepared before mutant starts, then copies that file for each worker process.

Run the Rails test database preparation step before starting mutant:

```sh
RAILS_ENV=test bin/rails db:test:prepare
```

Then configure a hook file that copies the prepared database for every worker:

```ruby
# rails_hooks.rb
require 'fileutils'

hooks.register(:env_infection_post) do
  Rails.application.eager_load!
end

project_root = File.expand_path('.', __dir__)
template_database = File.join(project_root, 'storage/test.sqlite3')
worker_database_dir = File.join(project_root, 'tmp/mutant')

disconnect_database = lambda do
  next unless defined?(ActiveRecord::Base)
  next unless ActiveRecord::Base.connected?

  ActiveRecord::Base.connection_pool.disconnect!
end

isolate_database = lambda do |index:|
  connection_config = ActiveRecord::Base.connection_db_config.configuration_hash

  disconnect_database.call

  unless File.file?(template_database)
    raise "Missing #{template_database}; run bin/rails db:test:prepare before mutant"
  end

  FileUtils.mkdir_p(worker_database_dir)

  database = File.join(worker_database_dir, "worker-#{index}-#{Process.pid}.sqlite3")
  FileUtils.cp(template_database, database)

  ENV['DATABASE_URL'] = "sqlite3:#{database}"
  ActiveRecord::Base.establish_connection(connection_config.merge(database: database))
end

hooks.register(:setup_integration_post) do
  disconnect_database.call
end

hooks.register(:test_worker_process_start) do |index:|
  isolate_database.call(index: index)
end

hooks.register(:mutation_worker_process_start) do |index:|
  isolate_database.call(index: index)
end
```

What this does:

- **`env_infection_post`** — eager-loads the application so subjects are discoverable.
- **`setup_integration_post`** — disconnects the parent process from the template database after the test integration has loaded.
- **`test_worker_process_start`** and **`mutation_worker_process_start`** — copy the prepared SQLite database file, then reconnect Active Record to the worker-specific copy. Both registrations are required if you use both `mutant test` and `mutant run`.

This pattern assumes the hook file lives at the Rails root and the test database lives at `storage/test.sqlite3`. Adjust `project_root` and `template_database` if your application uses different paths. Applications with multiple SQLite databases need to copy and reconnect each database separately.

## Other Databases

The hook event structure (`setup_integration_post` for the initial disconnect, `test_worker_process_start` / `mutation_worker_process_start` for per-worker setup) applies to any database. What changes is how the worker-specific database is created and selected:

- **MySQL** — connect as a privileged user, `CREATE DATABASE` per worker, then run your schema-load step (e.g. `db:schema:load`) since MySQL has no `TEMPLATE` clause.
- **Multiple databases** — extend `base_records` with each abstract base class (e.g. `[ApplicationRecord, AnalyticsRecord]`); the same hooks run per base.

## Test Runner Notes

Mutant's test runner uses dynamic work allocation: workers pull tests from a shared queue. This is particularly effective for Rails projects, where integration tests have widely variable runtimes — fast workers automatically pick up more work instead of sitting idle while a slow worker grinds through a long request spec. See [Test Runner: differences from native test runners](/docs/test-runner.md#differences-from-native-test-runners) for details.

## Other Resources

Consider isolation for any worker-shared state, not just databases:

- File system (temp directories, ActiveStorage roots, fixture uploads)
- Caches (Redis / Memcached — namespace per worker index)
- External services (use test doubles or per-worker endpoints)
- Background queues (separate Sidekiq / GoodJob namespaces)

The same hook events that isolate the database (`test_worker_process_start`, `mutation_worker_process_start`) are the right place to set these up.

## Debugging

If subjects are not matching or the application fails to load, see [Debugging: loading issues](/docs/debugging.md#debug-loading-issues). Quick checks:

```sh
# Confirm mutant sees the configuration you expect
bundle exec mutant environment show

# Drop into IRB with the full mutant environment loaded
bundle exec mutant environment irb

# Verify subjects are discoverable after eager loading
bundle exec mutant environment subject list MyNamespace*
```

If `subject list` returns nothing for a namespace you know exists, the eager-load hook is almost certainly missing or not running.
