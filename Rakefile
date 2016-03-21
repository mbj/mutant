require 'devtools'

Devtools.init_rake_tasks

Rake.application.load_imports

task('metrics:mutant').clear
namespace :metrics do
  task mutant: :coverage do
    arguments = %w[
      bundle exec mutant
      --ignore-subject Mutant::Meta*
      --include lib
      --since HEAD~1
      --require mutant
      --use rspec
      --zombie
    ]
    arguments.concat(%w[--jobs 4]) if ENV.key?('CIRCLE_CI')

    arguments.concat(%w[-- Mutant*])

    Kernel.system(*arguments) or fail 'Mutant task is not successful'
  end
end
