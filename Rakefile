require 'devtools'
Devtools.init_rake_tasks

class Rake::Task
  def overwrite(&block)
    @actions.clear
    enhance(&block)
  end
end

Rake.application.load_imports

Rake::Task['metrics:mutant'].overwrite do
  $stderr.puts "Mutant self mutation (Zombie) is deactivated"
# project = Devtools.project
# require File.expand_path('../spec/support/zombie.rb', __FILE__)
# Zombie.setup
# status = Zombie::CLI.run(%W(::Mutant --rspec-dm2))
# if status.nonzero?
#   $stderr.puts 'Zombie task is not successful'
#   $stderr.puts 'Not fatal at this point of development, will be fixed before release of 0.3.0'
# end
end
