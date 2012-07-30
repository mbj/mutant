require 'spec_helper'

describe Mutant::Mutator::Generator,'#append' do
  subject { object.append(node) }

  class Block
    attr_reader :arguments

    def called?
      defined?(@arguments)
    end

    def call(*arguments)
      @arguments = arguments
    end
  end

  let(:object)       { described_class.new(wrapped_node,block) }
  let(:block)        { Block.new                               }
  let(:wrapped_node) { '"foo"'.to_ast                          }

  context 'with node that is not equal to wrapped node' do
    let(:node) { '"bar"'.to_ast }

    it 'should call block' do
      subject
      block.should be_called
    end

    it 'should call block with node' do
      subject
      block.arguments.should eql([node])
    end
  end
  
  context 'with node that is equal to wrapped node' do
    let(:node) { '"foo"'.to_ast }

    it 'should call block' do
      subject
      block.should_not be_called
    end
  end
end
