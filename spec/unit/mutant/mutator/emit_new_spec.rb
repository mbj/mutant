require 'spec_helper'

describe Mutant::Mutator, '#emit_new' do
  subject { object.send(:emit_new) { node } }

  class Block
    def arguments; @arguments; end

    def called?
      defined?(@arguments)
    end

    def call(*arguments)
      @arguments = arguments
    end
  end

  let(:object)       { class_under_test.new(wrapped_node, block) }
  let(:block)        { Block.new                                }
  let(:wrapped_node) { '"foo"'.to_ast                           }

  let(:class_under_test) do
    Class.new(described_class) do
      def dispatch
        #noop
      end
    end
  end

  context 'when new AST is generated' do
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

  context 'when new AST could not be generated' do
    let(:node) { '"foo"'.to_ast }

    it 'should raise error' do
      expect { subject }.to raise_error(RuntimeError, 'New AST could not be generated after 3 attempts')
    end
  end
end
