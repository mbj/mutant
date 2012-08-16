require 'spec_helper'

describe Mutant,'rspec integration' do
  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  specify 'allows to run rspec with mutations' do

    Mutant::Matcher::Method.parse('TestApp::Literal#string').each do |subject|
      subject.each do |mutation|
        runner =  Mutant::Killer::Rspec.run(mutation)
        runner.fail?.should be(false)
      end
      subject.reset
    end

    Mutant::Matcher::Method.parse('TestApp::Literal#uncovered_string').each do |subject|
      subject.each do |mutation|
        runner =  Mutant::Killer::Rspec.run(mutation)
        runner.fail?.should be(true)
      end
      subject.reset
    end

  end
end
