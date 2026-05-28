# Rails Integration

Rails applications have specific requirements when running under mutant: the application must be initialized in test mode, all subjects must be loaded eagerly so they are discoverable, and parallel workers need isolated database resources to avoid conflicts.

This document is the canonical reference for setting up mutant against a Rails application. The hook recipes below are verified on every non-EOL Rails version (currently **7.2, 8.0 and 8.1**) against both PostgreSQL and SQLite by a runnable example app — see [Verified example](#verified-example). The mechanisms it relies on are documented in:

- [Configuration](/docs/configuration.md) — the configuration file format
- [Hooks](/docs/hooks.md) — the hooks system used for eager loading and resource isolation
- [Test Runner](/docs/test-runner.md) — parallel execution and resource isolation
- [RSpec Integration](/docs/mutant-rspec.md) / [Minitest Integration](/docs/mutant-minitest.md) — test framework integrations

## Minimal Setup

A working Rails configuration needs three things in `config/mutant.yml`:

```yml
---
requires:
  - ./config/environment

environment_variables:
  RAILS_ENV: test

integration:
  name: rspec   # or minitest

hooks:
  - config/mutant/hooks.rb
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
hooks.register(:env_infection_post) do
  Rails.application.eager_load!
end
```

This is the recommended baseline for any Rails project, even when no other hooks are needed. Without it, subject expressions can silently match nothing. The database-isolation recipes below already include this hook.

See the [hooks reference](/docs/hooks.md#available-hooks) for the full list of hook events.

## Database Isolation for Parallel Workers (PostgreSQL)

> **PostgreSQL-specific.** The example below uses the `pg` driver (`PG.connect`, `PG::Connection`) and the `CREATE DATABASE ... TEMPLATE` clause. The hook structure is portable to other adapters (see [Other Databases](#other-databases) below), but the code as written will not run against MySQL, SQLite, or other engines.

When running with multiple workers (the default), each worker shares the same Rails process layout and therefore the same database configuration. Without isolation, workers fight over the same tables and tests become non-deterministic.

The recipe below creates a per-worker copy of the test database using PostgreSQL's `TEMPLATE` clause. Each worker gets its own database (`<test_db>_mutant_worker_<index>`) cloned from the template at process start. Save it as `config/mutant/hooks.rb` (the path referenced by `config/mutant.yml`):

<!-- BEGIN config/mutant/hooks_postgresql.rb -->
```ruby
# The abstract base classes whose connection pools need a per-worker database.
# A single-database app has just ActiveRecord::Base; add each additional
# abstract base class (e.g. AnalyticsRecord) here if the app connects to more
# than one database, and the hooks below will isolate each of them per worker.
#
# If those base classes use different database engines (e.g. one on PostgreSQL
# and one on SQLite), merge this recipe with the SQLite one and branch on
# base.connection_pool.db_config.adapter inside the loop.
base_records = -> { [ActiveRecord::Base] }

disconnect_pool = ->(base:) { base.connection_pool.disconnect! }

with_root_connection = lambda do |db_config, &block|
  config     = db_config.configuration_hash
  connection = PG.connect(
    host:     config[:host],
    port:     config[:port],
    user:     config[:username],
    password: config[:password],
    dbname:   'postgres'
  )

  begin
    block.call(connection)
  ensure
    connection.close
  end
end

isolate_database = lambda do |base:, index:|
  db_config = base.connection_pool.db_config
  template  = db_config.database
  isolated  = "#{template}_mutant_worker_#{index}"

  with_root_connection.call(db_config) do |connection|
    quoted_template = PG::Connection.quote_ident(template)
    quoted_isolated = PG::Connection.quote_ident(isolated)

    connection.exec("DROP DATABASE IF EXISTS #{quoted_isolated}")
    connection.exec("CREATE DATABASE #{quoted_isolated} TEMPLATE #{quoted_template}")
  end

  db_config._database = isolated
end

isolate_index = lambda do |index:|
  base_records.call.each do |base|
    disconnect_pool.call(base:)
    isolate_database.call(base:, index:)
  end
end

hooks.register(:env_infection_post) do
  Rails.application.eager_load!
end

hooks.register(:setup_integration_post) do
  base_records.call.each { |base| disconnect_pool.call(base:) }
end

hooks.register(:test_worker_process_start)     { |index:| isolate_index.call(index:) }
hooks.register(:mutation_worker_process_start) { |index:| isolate_index.call(index:) }
```
<!-- END config/mutant/hooks_postgresql.rb -->

What this does:

The actual per-worker database setup happens in the *worker-start* hooks. The other two hooks set up preconditions in the parent process.

- **`mutation_worker_process_start`** and **`test_worker_process_start`** — the core of the recipe. Both run `isolate_index`, which fires once inside each forked worker process: for every base class it drops the inherited connection pool, opens a root connection via the raw `pg` driver (`PG.connect` to the `postgres` maintenance database), runs `CREATE DATABASE … TEMPLATE`, and rebinds `db_config._database` to the per-worker name. The two hooks fire under different commands — `mutation_worker_process_start` under `mutant run`, `test_worker_process_start` under `mutant test` — so **both registrations are required** if you want isolation in both modes. Drop one and that command's workers will trample each other on the shared template database.
- **`setup_integration_post`** — releases the parent's connection to the template database so workers *can* use it as a `TEMPLATE`. PostgreSQL refuses `CREATE DATABASE … TEMPLATE myapp_test` while any session (including the parent's RSpec/Minitest connection opened during integration setup) is connected to `myapp_test`. Without this hook the first worker's `CREATE DATABASE` errors with `source database "myapp_test" is being accessed by other users`. Fires in both `mutant run` and `mutant test`.
- **`env_infection_post`** — eager-loads the application so subjects are discoverable (see [Recommended Hook: Eager Load](#recommended-hook-eager-load) above). Fires in both `mutant run` and `mutant test`.

`PG.connect` reads its host, port, user and password from the connection's `configuration_hash`, so the same recipe works whether the application is configured with a `DATABASE_URL` or with discrete keys in `config/database.yml`. The root connection targets the `postgres` maintenance database because you cannot `CREATE`/`DROP` a database while connected to it.

The `mutant test` case is worth calling out explicitly: this same hook file lets you run `mutant test` as a drop-in parallel test runner (no mutations), with the same per-worker database isolation — provided you registered `test_worker_process_start`. See [Test Runner](/docs/test-runner.md) for that workflow.

## Database Isolation for Parallel Workers (SQLite)

> **SQLite-specific.** SQLite database files should not be shared by parallel workers. The recipe below uses a test database file prepared before mutant starts, then copies that file for each worker process.

Run the Rails test database preparation step before starting mutant:

```sh
RAILS_ENV=test bin/rails db:test:prepare
```

Then save the following as `config/mutant/hooks.rb`. It copies the prepared database for every worker:

<!-- BEGIN config/mutant/hooks_sqlite.rb -->
```ruby
# The abstract base classes whose databases need a per-worker copy.
# A single-database app has just ActiveRecord::Base; add each additional
# abstract base class (e.g. AnalyticsRecord) here if the app connects to more
# than one database, and the hooks below will isolate each of them per worker.
#
# If those base classes use different database engines (e.g. one on SQLite and
# one on PostgreSQL), merge this recipe with the PostgreSQL one and branch on
# base.connection_pool.db_config.adapter inside the loop.
base_records = -> { [ActiveRecord::Base] }

worker_database_dir = File.join(Dir.pwd, 'tmp/mutant')

disconnect_pool = ->(base:) { base.connection_pool.disconnect! }

isolate_database = lambda do |base:, index:|
  connection_config = base.connection_pool.db_config.configuration_hash
  template          = connection_config.fetch(:database)

  unless File.file?(template)
    raise "Missing #{template}; run bin/rails db:test:prepare before mutant"
  end

  FileUtils.mkdir_p(worker_database_dir)

  name     = File.basename(template, '.*')
  isolated = File.join(worker_database_dir, "#{name}_mutant_worker_#{index}.sqlite3")
  FileUtils.cp(template, isolated)

  base.establish_connection(connection_config.merge(database: isolated))
end

isolate_index = lambda do |index:|
  base_records.call.each do |base|
    disconnect_pool.call(base:)
    isolate_database.call(base:, index:)
  end
end

hooks.register(:env_infection_post) do
  Rails.application.eager_load!
end

hooks.register(:setup_integration_post) do
  base_records.call.each { |base| disconnect_pool.call(base:) }
end

hooks.register(:test_worker_process_start)     { |index:| isolate_index.call(index:) }
hooks.register(:mutation_worker_process_start) { |index:| isolate_index.call(index:) }
```
<!-- END config/mutant/hooks_sqlite.rb -->

What this does:

- **`env_infection_post`** — eager-loads the application so subjects are discoverable.
- **`setup_integration_post`** — disconnects the parent process from the template database after the test integration has loaded.
- **`test_worker_process_start`** and **`mutation_worker_process_start`** — run `isolate_index`, which for every base class copies the prepared SQLite file to a worker-specific path under `tmp/mutant`, then reconnects Active Record to the copy. Both registrations are required if you use both `mutant test` and `mutant run`.

This recipe assumes the test database lives at the path Active Record reports for each base class (`bin/rails db:test:prepare` writes it there). Applications with multiple SQLite databases list each abstract base class in `base_records`; every one is copied and reconnected separately.

## Verified example

A complete, runnable version of this setup lives in [`rails_example/`](/rails_example) at the repository root: a minimal Rails app, the two hook recipes above (`config/mutant/hooks_postgresql.rb` and `config/mutant/hooks_sqlite.rb`), and a single `Gemfile` parameterized by `RAILS_VERSION`. CI runs it for Rails 7.2, 8.0 and 8.1 against both databases via `manager ruby rails-verify` (PostgreSQL is provisioned on demand by the [`pg-ephemeral`](https://rubygems.org/gems/pg-ephemeral) gem). The fenced recipes above are kept byte-identical to those files by a guard spec, so what you copy from here is exactly what is tested.

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
