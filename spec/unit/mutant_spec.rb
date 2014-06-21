require 'spec_helper'

describe Mutant do
  describe '.singleton_subclass_instance' do
    let(:object) { described_class }

    subject { object.singleton_subclass_instance(name, superclass, &block) }

    before { subject }

    let(:name)       { 'Test'                }
    let(:block)      { proc { def foo; end } }
    let(:superclass) { Class.new             }

    let(:generated) { superclass.const_get(:Test) }

    it_should_behave_like 'a command method'

    it 'sets expected name' do
      name = generated.class.name
      expect(name).to eql("::#{self.name}")
      expect(name).to be_frozen
    end

    it 'stores instance of subclass' do
      expect(generated).to be_kind_of(superclass)
    end

    it 'evaluates the context of proc inside subclass' do
      expect(generated).to respond_to(:foo)
    end

    it 'generates nice #inspect' do
      inspect = generated.inspect
      expect(inspect).to eql("::#{self.name}")
      expect(inspect).to be_frozen
    end
  end
end
