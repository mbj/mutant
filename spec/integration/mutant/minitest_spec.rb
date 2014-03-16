# encoding: utf-8

require 'spec_helper'

describe Mutant, 'minitest integration' do

  let(:base_cmd) { 'bundle exec mutant -I lib --require test_app --use minitest' }

  context 'Mintest on stdlib' do
    let(:gemfile) { 'Gemfile.minitest-stdlib' }

    it_behaves_like 'mutant integration'
  end
end
