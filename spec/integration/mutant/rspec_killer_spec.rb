# encoding: utf-8

require 'spec_helper'

describe Mutant, 'rspec integration' do

  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  let(:strategy) { Mutant::Strategy::Rspec::DM2 }

  pending 'allows to kill mutations' do
    cli = 'bundle exec mutant --rspec ::TestApp::Literal#string'
    Kernel.system(cli).should be(true)
  end

  pending 'fails to kill mutations when they are not covered' do
    cli = 'bundle exec mutant --rspec ::TestApp::Literal#uncovered_string'
    Kernel.system(cli).should be(false)
  end

  pending 'fails when some mutations when are not covered' do
    cli = 'bundle exec mutant --rspec ::TestApp::Literal'
    Kernel.system(cli).should be(false)
  end
end
