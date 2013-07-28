require 'spec_helper'

describe Mutant::Mutator, '#emit_new' do
  subject { object.send(:emit_new) { generated } }

  class Block
    attr_reader :arguments

    def called?
      defined?(@arguments)
    end

    def call(*arguments)
      @arguments = arguments
    end
  end

  let(:object) { class_under_test.new(input, parent, block) }
  let(:block)  { Block.new                                  }
  let(:input)  { :input                                     }
  let(:parent) { :parent                                    }

  let(:class_under_test) do
    Class.new(described_class) do
      def dispatch
        # noop
      end
    end
  end

  context 'when new object generated' do
    let(:generated) { :generated }

    it 'should call block' do
      subject
      block.should be_called
    end

    it 'should call block with generated object' do
      subject
      block.arguments.should eql([generated])
    end
  end

  context 'when new AST could not be generated' do
    let(:generated) { input }

    it 'should raise error' do
      expect { subject }.to raise_error(RuntimeError, 'New AST could not be generated after 3 attempts')
    end
  end
end
