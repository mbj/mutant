# encoding: utf-8

require 'devtools'

Devtools.init_rake_tasks

Rake.application.load_imports
task('metrics:mutant').clear

namespace :metrics do
  task :mutant => :coverage do
    $stderr.puts 'Mutant self mutation is disable till mutant is fast enough for travis'
  end
end
