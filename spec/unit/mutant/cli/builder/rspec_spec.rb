# encoding: utf-8

require 'spec_helper'

describe Mutant::CLI::Builder::Rspec do

  let(:option_parser) { OptionParser.new }

  let(:cache)  { Mutant::Cache.new                         }
  let(:object) { described_class.new(cache, option_parser) }
  let(:level)  { double('Level')                           }

  let(:default_strategy) do
    Mutant::Strategy::Rspec.new(0)
  end

  let(:altered_strategy) do
    Mutant::Strategy::Rspec.new(1)
  end

  describe 'default' do
    specify do
      object
      option_parser.parse!(%w[--rspec])
      expect(object.output).to eql(default_strategy)
    end
  end

  describe 'parsing a level' do

    specify do
      object
      option_parser.parse!(%w[--rspec --rspec-level 1])
      expect(object.output).to eql(altered_strategy)
    end
  end

end
