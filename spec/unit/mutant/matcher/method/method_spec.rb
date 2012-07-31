require 'spec_helper'

describe Mutant::Matcher::Method, '#method' do
  subject { object.send(:method) }

  let(:object) { described_class.allocate }

  it 'should raise error' do
    expect { subject }.to raise_error(NotImplementedError, 'Mutant::Matcher::Method#method is not implemented')
  end
end
