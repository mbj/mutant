require 'spec_helper'

describe Mutant, 'rspec integration' do

  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  let(:strategy) { Mutant::Strategy::Rspec::DM2 }

  specify 'allows to kill mutations' do
    cli = 'bundle exec mutant --rspec-dm2 ::TestApp::Literal#string'
    Kernel.system(cli).should be(true)
  end

  specify 'fails to kill mutations when they are not covered' do
    cli = 'bundle exec mutant --rspec-dm2 ::TestApp::Literal#uncovered_string'
    Kernel.system(cli).should be(false)
  end

  specify 'fails when some mutations when are not covered' do
    cli = 'bundle exec mutant --rspec-dm2 ::TestApp::Literal'
    Kernel.system(cli).should be(false)
  end
end
