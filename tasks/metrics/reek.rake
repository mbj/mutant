begin
  require 'reek/rake/task'

  if defined?(RUBY_ENGINE) and RUBY_ENGINE == 'rbx'
    task :reek do
      $stderr.puts 'Reek fails under rubinius, fix rubinius and remove guard'
    end
  else
    Reek::Rake::Task.new
  end
rescue LoadError
  task :reek do
    $stderr.puts 'Reek is not available. In order to run reek, you must: gem install reek'
  end
end
