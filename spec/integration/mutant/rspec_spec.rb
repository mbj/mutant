# encoding: utf-8

require 'spec_helper'

describe Mutant, 'rspec integration' do

  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  specify 'it allows to kill mutations' do
    Kernel.system('bundle exec mutant -I lib --require test_app --rspec ::TestApp::Literal#string').should be(true)
  end

  specify 'it allows to exclude mutations' do
    Kernel.system('bundle exec mutant -I lib --require test_app --rspec ::TestApp::Literal#string --ignore-subject ::TestApp::Literal#uncovered_string').should be(true)
  end


  specify 'fails to kill mutations when they are not covered' do
    cli = 'bundle exec mutant -I lib --require test_app --rspec ::TestApp::Literal#uncovered_string'
    Kernel.system(cli).should be(false)
  end

  specify 'fails when some mutations are not covered' do
    cli = 'bundle exec mutant -I lib --require test_app --rspec ::TestApp::Literal'
    Kernel.system(cli).should be(false)
  end
end
