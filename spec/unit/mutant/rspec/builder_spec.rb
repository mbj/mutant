# encoding: utf-8

require 'spec_helper'

describe Mutant::Rspec::Builder do

  let(:option_parser) { OptionParser.new }

  let(:cache)  { Mutant::Cache.new                         }
  let(:object) { described_class.new(cache, option_parser) }

  let(:default_strategy) do
    Mutant::Rspec::Strategy.new
  end

  specify do
    object
    option_parser.parse!(%w[--rspec])
    expect(object.output).to eql(default_strategy)
  end
end
