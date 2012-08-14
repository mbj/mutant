require 'spec_helper'

describe Mutant, 'runner' do
  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  it 'allows to run mutant over a project' do
    Mutant::Killer::Rspec.nest do
      report = Mutant::Runner.run(
        :pattern => /\ATestApp::/,
        :killer => Mutant::Killer::Rspec
      )
      report.errors.size.should be(18)
    end
  end
end
