require 'spec_helper'

describe Mutant, 'runner' do
  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  it 'allows to run mutant over a project' do
    runner = Mutant::Runner.run(
      :pattern => /\ATestApp::/,
      :killer => Mutant::Killer::Rspec,
      :reporter => Mutant::Reporter::CLI.new($stdout)
    )
    runner.fail?.should be(true)
  end
end
