RSpec.describe Mutant::Mutator::Registry do
  describe '#lookup' do
    subject { Mutant::Mutator::REGISTRY.lookup(node) }

    context 'on registered node' do
      let(:node) { s(:true) }

      it { should eql(Mutant::Mutator::Node::Literal::Boolean) }
    end

    context 'on unknown node' do
      let(:node) { s(:unknown) }

      it 'raises error' do
        expect { subject }.to raise_error(described_class::RegistryError, 'No mutator to handle: :unknown')
      end
    end
  end

  describe '#register' do
    let(:object) { described_class.new }

    let(:mutator) { instance_double(Mutant::Mutator) }

    subject { object.register(type, mutator) }

    context 'when registering an invalid node type' do
      let(:type) { :invalid }

      it 'raises error' do
        expect { subject }.to raise_error(described_class::RegistryError, 'Invalid type registration: invalid')
      end
    end

    context 'when registering a valid node type' do
      let(:type) { :true }

      it 'allows to lookup mutator' do
        subject
        expect(object.lookup(s(type))).to be(mutator)
      end

      it_behaves_like 'a command method'
    end

    context 'when duplicate the registration of a valid node type' do
      let(:type) { :true }

      it 'allows to lookup mutator' do
        object.register(type, mutator)
        expect { subject }.to raise_error(described_class::RegistryError, 'Duplicate type registration: true')
      end

      it_behaves_like 'a command method'
    end
  end
end
