# encoding: utf-8

require 'spec_helper'

describe Mutant, 'rspec integration' do

  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  specify 'it allows to kill mutations' do
    Kernel.system('bundle exec mutant --rspec ::TestApp::Literal#string').should be(true)
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
