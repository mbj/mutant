# encoding: utf-8

require 'spec_helper'

# This spec is only present to ensure 100% test coverage.
# The code should not be triggered on runtime.

describe Mutant::Matcher, '#each' do
  subject { object.send(:each) }

  let(:object) { described_class.allocate }

  it 'should raise error' do
    expect do
      subject
    end.to raise_error(
      NotImplementedError,
      'Mutant::Matcher#each is not implemented'
    )
  end
end
