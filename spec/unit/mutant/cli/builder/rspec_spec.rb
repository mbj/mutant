require 'spec_helper'

describe Mutant::CLI::Builder::Rspec do
  let(:object) { described_class.new }

  describe '#strategy' do
    let(:level) { double('Level') }

    it { should eql(Mutant::Strategy::Rspec.new(level)) }
  end
end
