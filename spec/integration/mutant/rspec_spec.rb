# encoding: utf-8

require 'spec_helper'

describe Mutant, 'rspec integration' do

  let(:base_cmd) { 'bundle exec mutant -I lib --require test_app --use rspec' }

  context 'RSpec 2' do
    let(:gemfile) { 'Gemfile.rspec2' }

    it_behaves_like 'mutant integration'
  end

  context 'Rspec 3' do
    let(:gemfile) { 'Gemfile.rspec3' }

    it_behaves_like 'mutant integration'
  end
end
