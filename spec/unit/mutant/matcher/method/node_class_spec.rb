require 'spec_helper'

describe Mutant::Matcher::Method, '#node_class' do
  subject { object.send(:node_class) }

  let(:object) { described_class.allocate }

  it 'should raise error' do
    expect { subject }.to raise_error(NotImplementedError, 'Mutant::Matcher::Method#node_class is not implemented')
  end
end

