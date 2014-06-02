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
