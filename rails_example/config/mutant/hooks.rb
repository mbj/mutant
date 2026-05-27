# frozen_string_literal: true

# Example-only dispatcher.
#
# This example app verifies BOTH documented database-isolation recipes from a
# single Rails application. A real project would simply point config/mutant.yml
# at one recipe file directly; here we select the one matching the database
# under verification (DB_ADAPTER, the same variable config/database.yml reads).
#
# We `eval` the recipe in this binding rather than `require` it because mutant
# loads each hook file with the `hooks` builder as a local variable
# (see Mutant::Hooks.load_pathname); a required file would not see `hooks`.
#
# hooks_postgresql.rb and hooks_sqlite.rb are kept byte-identical to the
# snippets in docs/rails.md by spec/unit/mutant/rails_docs_hooks_spec.rb.
recipe =
  case ENV.fetch('DB_ADAPTER', 'sqlite3')
  when 'postgresql' then 'hooks_postgresql.rb'
  else 'hooks_sqlite.rb'
  end

path = File.join(Dir.pwd, 'config', 'mutant', recipe)

eval(File.read(path), binding, path) # rubocop:disable Security/Eval
