# frozen_string_literal: true

RSpec.describe Mutant::Registry do
  let(:mutator) { class_double(Mutant::Mutator) }
  let(:object)  { described_class.new           }

  describe '#lookup' do
    subject { object.lookup(type) }

    def register
      object.register(type, mutator)
    end

    context 'on known type' do
      let(:type) { :true }

      it 'returns registered' do
        register
        expect(subject).to be(mutator)
      end
    end

    context 'on unknown type' do
      let(:type) { :unknown }

      it 'returns genericm mutator' do
        expect(subject).to be(Mutant::Mutator::Node::Generic)
      end
    end
  end

  describe '#register' do
    subject { object.register(type, mutator) }

    def lookup
      subject.lookup(type)
    end

    context 'on registered type' do
      let(:type) { :true }

      it_behaves_like 'a command method'

      it 'allows to lookup the mutator' do
        subject
        expect(lookup).to be(mutator)
      end

      context 'when registering twice' do
        it 'fails upon registration' do
          object.register(type, mutator)

          expect { subject }
            .to raise_error(
              described_class::RegistryError,
              'Duplicate type registration: :true'
            )
        end
      end
    end

    context 'when registering an invalid node type' do
      let(:type) { :invalid }

      it 'raises error' do
        expect { subject }
          .to raise_error(
            described_class::RegistryError,
            'Invalid type registration: :invalid'
          )
      end
    end
  end
end
