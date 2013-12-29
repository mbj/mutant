# encoding: utf-8

require 'spec_helper'

describe Mutant do
  describe '.singleton_subclass_instance' do
    let(:object) { described_class }

    subject { object.singleton_subclass_instance(name, superclass, &block) }

    before do
      subject
    end

    let(:name)       { 'Test'                }
    let(:block)      { proc { def foo; end } }
    let(:superclass) { Class.new             }

    let(:generated) { superclass.const_get(:Test) }

    it_should_behave_like 'a command method'

    it 'sets expected name' do
      name = generated.class.name
      name.should eql("::#{self.name}")
      name.should be_frozen
    end

    it 'stores instance of subclass' do
      generated.should be_kind_of(superclass)
    end

    it 'evaluates the context of proc inside subclass' do
      generated.should respond_to(:foo)
    end

    it 'generates nice #inspect' do
      inspect = generated.inspect
      inspect.should eql("::#{self.name}")
      inspect.should be_frozen
    end
  end
end
