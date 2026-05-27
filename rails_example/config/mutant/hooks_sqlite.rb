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
