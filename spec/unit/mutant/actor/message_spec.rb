RSpec.describe Mutant::Actor::Message do

  let(:type)    { double('Type')    }
  let(:payload) { double('Payload') }

  describe '.new' do
    subject { described_class.new(*arguments) }

    context 'with one argument' do
      let(:arguments) { [type] }

      its(:type)    { should be(type) }
      its(:payload) { should be(Mutant::Actor::Undefined) }
    end

    context 'with two arguments' do
      let(:arguments) { [type, payload] }

      its(:type)    { should be(type)    }
      its(:payload) { should be(payload) }
    end
  end
end
