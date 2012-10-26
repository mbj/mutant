require 'spec_helper'

describe Mutant, 'runner' do
  before do
    pending
  end

  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  it 'allows to run mutant over a project' do
    output = StringIO.new
    runner = Mutant::Runner.run(
      :killer => Mutant::Killer::Rspec,
      :matcher => Mutant::Matcher::ObjectSpace.new(/\ATestApp::/),
      :reporter => Mutant::Reporter::CLI.new(output)
    )
    runner.fail?.should be(true)
    runner.errors.size.should be(22)
    output.rewind
    output.lines.grep(/Mutant alive:/).size.should be(22)
  end
end
