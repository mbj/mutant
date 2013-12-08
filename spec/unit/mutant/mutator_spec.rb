# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator do

  let(:object)  { class_under_test.new(context, block) }

  let(:context) { described_class::Context.new(config, parent, input) }
  let(:block)   { Block.new                                           }
  let(:input)   { :input                                              }
  let(:parent)  { :parent                                             }
  let(:config)  { double('Config')                                    }

  class Block
    attr_reader :arguments

    def called?
      defined?(@arguments)
    end

    def call(*arguments)
      @arguments = arguments
    end
  end

  let(:class_under_test) do
    Class.new(described_class) do
      def dispatch
        # noop
      end
    end
  end

  describe '#emit' do

    subject { object.send(:emit, generated) }

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

  describe '#emit_new' do
    subject { object.send(:emit_new) { generated } }

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
        expect do
          subject
        end.to raise_error(
          RuntimeError,
          'New AST could not be generated after 3 attempts'
        )
      end
    end
  end
end
