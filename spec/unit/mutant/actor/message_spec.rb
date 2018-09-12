# frozen_string_literal: true

RSpec.describe Mutant::Actor::Message do

  let(:type)    { instance_double(Symbol) }
  let(:payload) { instance_double(Object) }

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
