require 'spec_helper'

describe Mutant::Mutator, '#emit' do
  subject { object.send(:emit, node) }

  class Block
    attr_reader :arguments

    def called?
      defined?(@arguments)
    end

    def call(*arguments)
      @arguments = arguments
    end
  end

  let(:object)       { class_under_test.new(wrapped_node, block) }
  let(:block)        { Block.new                               }
  let(:wrapped_node) { '"foo"'.to_ast                          }

  let(:class_under_test) do
    Class.new(described_class) do
      def dispatch
        #noop
      end
    end
  end

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
