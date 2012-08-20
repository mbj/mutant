require 'spec_helper'

describe Mutant, 'runner' do
  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  it 'allows to run mutant over a project' do
    output = StringIO.new
    runner = Mutant::Runner.run(
      :pattern => /\ATestApp::/,
      :killer => Mutant::Killer::Rspec,
      :reporter => Mutant::Reporter::CLI.new(output)
    )
    runner.fail?.should be(true)
    runner.errors.size.should be(22)
    output.rewind
    output.lines.grep(/Mutation/).size.should be(22)
  end
end
