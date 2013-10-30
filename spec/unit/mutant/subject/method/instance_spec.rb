require 'spec_helper'

describe Mutant::Subject::Method::Instance do
  include Mutant::NodeHelpers

  let(:object)  { described_class.new(context, node) }
  let(:context) { double }

  let(:node) do
    s(:def, :foo, s(:args))
  end

  describe '#source' do
    subject { object.source }

    it { should eql("def foo\nend") }
  end
end

describe Mutant::Subject::Method::Instance::Memoized do
  include Mutant::NodeHelpers

  let(:object)  { described_class.new(context, node) }
  let(:context) { double }

  let(:node) do
    s(:def, :foo, s(:args))
  end

  describe '#source' do
    subject { object.source }

    it { should eql("def foo\nend\nmemoize(:foo)") }
  end
end
