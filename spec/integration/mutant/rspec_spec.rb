# encoding: utf-8

require 'spec_helper'

describe Mutant, 'rspec integration' do

  around do |example|
    Dir.chdir(TestApp.root) do
      example.run
    end
  end

  let(:base_cmd) { 'bundle exec mutant -I lib --require test_app --use rspec' }

  specify 'it allows to kill mutations' do
    expect(Kernel.system("#{base_cmd} ::TestApp::Literal#string")).to be(true)
  end

  specify 'it allows to exclude mutations' do
    cli = "#{base_cmd} ::TestApp::Literal#string ::TestApp::Literal#uncovered_string --ignore-subject ::TestApp::Literal#uncovered_string"
    expect(Kernel.system(cli)).to be(true)
  end

  specify 'fails to kill mutations when they are not covered' do
    cli = "#{base_cmd} ::TestApp::Literal#uncovered_string"
    expect(Kernel.system(cli)).to be(false)
  end

  specify 'fails when some mutations are not covered' do
    cli = "#{base_cmd} ::TestApp::Literal"
    expect(Kernel.system(cli)).to be(false)
  end
end
