# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator, 'nthref' do
  context '$1' do
    let(:source)    { '$1' }
    let(:mutations) { ['$2', '$0']   }

    it_should_behave_like 'a mutator'
  end

  context '$2' do
    let(:source)    { '$2' }
    let(:mutations) { ['$3', '$1']   }

    it_should_behave_like 'a mutator'
  end
end
