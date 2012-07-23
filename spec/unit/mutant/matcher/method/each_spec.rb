require 'spec_helper'

# This method implementation cannot be called from the outside, but heckle needs to be happy.

describe Mutant::Matcher::Method,'#each' do
  let(:class_under_test) do
    node = self.root_node
    Class.new(described_class) do
      define_method(:root_node) do
        node
      end
    end
  end


  subject { object.each { |item| yields << item }  }

  let(:object) { class_under_test.allocate }
  let(:yields) { [] }

  it_should_behave_like 'an #each method'

  let(:root_node) { mock('Root Node') }

  context 'with match' do
    it 'should yield root node' do
      expect { subject }.to change { yields.dup }.from([]).to([root_node])
    end
  end

  context 'without match' do
    let(:root_node) { nil }

    it 'should yield nothing' do
      subject
      yields.should eql([])
    end
  end
end
