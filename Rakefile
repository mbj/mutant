require 'devtools'
Devtools.init_rake_tasks

namespace :metrics do
  desc 'Run mutant'
  task :mutant => :coverage do
    project = Devtools.project
    require File.expand_path('../spec/support/zombie.rb', __FILE__)
    Zombie.setup
    status = Zombie::CLI.run(%W(::Mutant --rspec-dm2))
    if status.nonzero?
      raise 'Mutant task is not successful'
    end
  end
end
