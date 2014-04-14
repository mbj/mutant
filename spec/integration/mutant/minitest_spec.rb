# encoding: utf-8

require 'spec_helper'

describe Mutant, 'minitest integration' do

  let(:base_cmd) { 'bundle exec mutant -I lib --require test_app --use minitest' }
  let(:gemfile)  { 'Gemfile.minitest-stdlib'                                     }

  context 'default run-all-integration ' do
    it_behaves_like 'mutant integration'
  end

  context 'with custom selections' do

    before do
      pending 'Write a clever test to prove it'
    end

  end
end
