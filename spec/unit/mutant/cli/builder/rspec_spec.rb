require 'spec_helper'

describe Mutant::CLI::Builder::Rspec do

  let(:object) { described_class.new }
  let(:level) { double('Level') }

  let(:default_strategy) do
    Mutant::Strategy::Rspec.new(0)
  end

  let(:altered_strategy) do
    Mutant::Strategy::Rspec.new(level)
  end

  describe '#set_level' do
    subject { object.set_level(level) }

    specify do
      expect { subject }.to change { object.strategy }.from(default_strategy).to(altered_strategy)
    end
  end

  describe '#strategy' do
    subject { object.strategy }

    context 'without setting a level' do
      it { should eql(Mutant::Strategy::Rspec.new(0)) }
    end

    context 'with setting a level' do

      before do
        object.set_level(level)
      end

      it { should eql(Mutant::Strategy::Rspec.new(level)) }
    end
  end
end
