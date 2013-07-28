# encoding: utf-8

require 'spec_helper'

describe Mutant::Killer, '#success?' do
  subject { object.success? }

  let(:object)           { class_under_test.new(strategy, mutation)    }
  let(:strategy)         { double('Strategy')                          }
  let(:mutation)         { double('Mutation', :success? => kill_state) }
  let(:kill_state)       { double('Kill State')                        }

  before do
    kill_state.stub(:freeze => kill_state, :dup => kill_state)
  end

  let(:class_under_test) do
    Class.new(described_class) do
      def run
      end
    end
  end

  it_should_behave_like 'an idempotent method'

  it 'should use kill state to gather success' do
    mutation.should_receive(:success?).with(object).and_return(kill_state)
    should be(kill_state)
  end
end
