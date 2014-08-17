require 'spec_helper'

describe Mutant::Config do
  describe '.load' do
    subject { described_class.load(input) }

    context 'with an input of appropriate type and format' do
      let(:input) do
        Mutant::Config::LOADER.inverse.call(Mutant::Config::DEFAULT)
      end

      it { should eql(Mutant::Config::DEFAULT) }
    end
  end
end
