RSpec.describe Mutant::Mutator do
  describe '.handle' do
    let(:object) { described_class }

    subject do
      Class.new(described_class) do
        const_set(:REGISTRY, Mutant::Mutator::Registry.new)

        handle :send

        def dispatch
          emit(parent)
        end
      end
    end

    it 'should register mutator' do
      expect(subject::REGISTRY.call(s(:send), s(:parent))).to eql([s(:parent)].to_set)
    end
  end
end
