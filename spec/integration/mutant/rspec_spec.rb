# encoding: utf-8

require 'spec_helper'

describe 'rspec integration' do

  let(:base_cmd) { 'bundle exec mutant -I lib --require test_app --use rspec' }

  shared_examples_for 'rspec integration' do
    around do |example|
      Bundler.with_clean_env do
        Dir.chdir(TestApp.root) do
          Kernel.system("bundle install --gemfile=#{gemfile}") || fail('Bundle install failed!')
          ENV['BUNDLE_GEMFILE'] = gemfile
          example.run
        end
      end
    end

    specify 'it allows to kill mutations' do
      expect(Kernel.system("#{base_cmd} ::TestApp::Literal#string")).to be(true)
    end

    specify 'it allows to exclude mutations' do
      cli = <<-CMD.split("\n").join(' ')
        #{base_cmd}
        ::TestApp::Literal#string
        ::TestApp::Literal#uncovered_string
          --ignore-subject ::TestApp::Literal#uncovered_string
      CMD
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

  context 'RSpec 2' do
    let(:gemfile) { 'Gemfile.rspec2' }

    it_behaves_like 'rspec integration'
  end

  context 'Rspec 3' do
    let(:gemfile) { 'Gemfile.rspec3' }

    it_behaves_like 'rspec integration'
  end
end
