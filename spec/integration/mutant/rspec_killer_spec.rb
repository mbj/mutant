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
        Mutant::Killer::Rspec.nest do 
          runner =  Mutant::Killer::Rspec.run(subject,mutation)
          runner.killed?.should be(true)
        end
      end
    end

    Mutant::Matcher::Method.parse('TestApp::Literal#uncovered_string').each do |subject|
      subject.each do |mutation|
        Mutant::Killer::Rspec.nest do 
          runner =  Mutant::Killer::Rspec.run(subject,mutation)
          runner.killed?.should be(false)
        end
      end
    end

  end
end
