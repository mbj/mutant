# encoding: utf-8

require 'devtools'

Devtools.init_rake_tasks

# Mutant self test is to slow for travis. Fast enough for circle.
if ENV['TRAVIS']
  Rake.application.load_imports

  task('metrics:mutant').clear
  namespace :metrics do
    task :mutant => :coverage do
      $stderr.puts 'Mutant self test via zombie not active on travis CI'
    end
  end
end
