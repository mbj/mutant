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
