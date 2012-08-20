$: << 'lib'
require 'mutant'
require 'rspec'
require './spec/support/zombie'

Zombie.setup

class MutantKiller < Zombie::Killer::Rspec
  def filename_pattern
    subject = mutation.subject
    matcher = subject.matcher
    context = subject.context

    path = context.scope.name.split('::').map do |name|
      name.downcase
    end.join('/')

    "spec/unit/#{path}"

   #case matcher
   #when Zombie::Matcher::Method::Singleton
   #when Zombie::Matcher::Method::Instance
   #else
   #  raise "Unkown matcher: #{matcher.class}"
   #end
  end
end

Zombie::Runner.run(
  :killer => MutantKiller,
  :pattern => /\AMutant(::|\z)/,
  :reporter => Zombie::Reporter::CLI.new($stderr)
)
