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
    arguments.concat(%W[--jobs 4]) if ENV.key?('CIRCLE_CI')

    arguments.concat(%w[-- Mutant*])

    success = Kernel.system(*arguments) or fail 'Mutant task is not successful'
  end
end

desc 'Generate mutation operator listing'
task :list do
  require 'mutant'
  # TODO: Add a nice public interface
  registry = Mutant::Mutator::Registry.send(:registry)
  registry.keys.select do |key|
    key.is_a?(Symbol)
  end.sort.each do |type|
    mutator = registry.fetch(type)
    puts '%-18s: %s' % [type, mutator.name.sub(/\AMutant::Mutator::Node::/, '')]
  end
end
