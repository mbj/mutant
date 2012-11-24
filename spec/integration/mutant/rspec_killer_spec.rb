require 'spec_helper'

describe Mutant,'rspec integration' do

  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  let(:strategy) { Mutant::Strategy::Rspec::DM2 }

  specify 'allows to kill mutations' do
    Kernel.system("bundle exec mutant -I lib -r test_app --rspec-dm2 ::TestApp::Literal#string").should be(true)
  end

  specify 'fails to kill mutations when they are not covered' do
    Kernel.system("bundle exec mutant -I lib -r test_app --rspec-dm2 ::TestApp::Literal#uncovered_string").should be(false)
  end

  specify 'fails when some mutations when are not covered' do
    Kernel.system("bundle exec mutant -I lib -r test_app --rspec-dm2 ::TestApp::Literal").should be(false)
  end
end
