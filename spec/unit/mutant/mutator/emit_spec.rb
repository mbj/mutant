# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator, '#emit' do
  subject { object.send(:emit, generated) }

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

  context 'with generated that is not equal to input' do
    let(:generated) { :generated }

    it 'should call block' do
      subject
      block.should be_called
    end

    it 'should call block with generated' do
      subject
      block.arguments.should eql([generated])
    end
  end

  context 'with generated object that is equal to input' do
    let(:generated) { input }

    it 'should not call block' do
      subject
      block.should_not be_called
    end
  end
end
