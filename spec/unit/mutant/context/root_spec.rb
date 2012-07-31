require 'spec_helper'

describe Mutant::Context, '#root' do
  subject { object.root(mock) }

  let(:object) { described_class.allocate }

  it 'should raise error' do
    expect { subject }.to raise_error('Mutant::Context#root is not implemented')
  end
end
