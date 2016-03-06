RSpec.describe Mutant::Mutator::Registry do
  let(:object)             { described_class.new           }
  let(:mutator)            { class_double(Mutant::Mutator) }
  let(:node)               { s(:true)                      }
  let(:expected_arguments) { [node, nil]                   }

  before do
    allow(mutator).to receive(:call).with(*expected_arguments).and_return([s(:nil)])
  end

  describe '#call' do
    let(:call_arguments) { [node] }

    subject { object.call(*call_arguments) }

    before do
      object.register(:true, mutator)
    end

    context 'on parent given' do
      let(:call_arguments)     { [node, s(:and)] }
      let(:expected_arguments) { call_arguments  }

      it { should eql([s(:nil)]) }
    end

    context 'on registered node' do
      let(:node) { s(:true) }

      it { should eql([s(:nil)]) }
    end

    context 'on unknown node' do
      let(:node) { s(:unknown) }

      it 'raises error' do
        expect { subject }.to raise_error(described_class::RegistryError, 'No mutator to handle: :unknown')
      end
    end
  end

  describe '#register' do
    subject { object.register(type, mutator) }

    context 'when registering an invalid node type' do
      let(:type) { :invalid }

      it 'raises error' do
        expect { subject }.to raise_error(described_class::RegistryError, 'Invalid type registration: :invalid')
      end
    end

    context 'when registering a valid node type' do
      let(:type) { :true }

      it 'allows to call mutator' do
        subject
        expect(object.call(s(type))).to eql([s(:nil)])
      end

      it_behaves_like 'a command method'
    end

    context 'when duplicate the registration of a valid node type' do
      let(:type) { :true }

      it 'allows to lookup mutator' do
        object.register(type, mutator)
        expect { subject }.to raise_error(described_class::RegistryError, 'Duplicate type registration: :true')
      end

      it_behaves_like 'a command method'
    end
  end
end
