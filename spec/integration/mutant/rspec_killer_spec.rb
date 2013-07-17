require 'spec_helper'

describe Mutant,'rspec integration' do

  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  pending 'allows to kill mutations' do
    Kernel.system('bundle exec mutant --rspec ::TestApp::Literal#string').should be(true)
  end

  pending 'fails to kill mutations when they are not covered' do
    Kernel.system('bundle exec mutant --rspec ::TestApp::Literal#uncovered_string').should be(false)
  end

  pending 'fails when some mutations are not covered' do
    Kernel.system('bundle exec mutant --rspec ::TestApp::Literal').should be(false)
  end
end
