# encoding: utf-8

require 'spec_helper'

describe Mutant::Context, '#root' do
  subject { object.root }

  let(:object) { described_class.allocate }

  it 'should raise error' do
    expect do
      subject
    end.to raise_error('Mutant::Context#root is not implemented')
  end
end
