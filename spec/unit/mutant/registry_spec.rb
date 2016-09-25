RSpec.describe Mutant::Registry do
  let(:lookup)  { object.lookup(type)           }
  let(:object)  { described_class.new           }
  let(:mutator) { class_double(Mutant::Mutator) }

  def register_mutator
    object.register(type, mutator)
  end

  context 'on registered type' do
    subject { register_mutator }

    let(:type) { :true }

    before { subject }

    it 'returns registered mutator' do
      expect(lookup).to be(mutator)
    end

    it_behaves_like 'a command method'

    context 'when registered twice' do
      it 'fails upon registration' do
        expect { register_mutator }.to raise_error(described_class::RegistryError, 'Duplicate type registration: :true')
      end
    end
  end

  context 'on unknown type' do
    let(:type) { :unknown }

    it 'raises error' do
      expect { lookup }.to raise_error(described_class::RegistryError, 'No entry for: :unknown')
    end
  end

  context 'when registering an invalid node type' do
    let(:type) { :invalid }

    it 'raises error' do
      expect { register_mutator }.to raise_error(described_class::RegistryError, 'Invalid type registration: :invalid')
    end
  end
end
