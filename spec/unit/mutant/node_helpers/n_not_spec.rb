# encoding: utf-8

require 'spec_helper'

describe Mutant::NodeHelpers, '#n_not' do
  subject { object.n_not(node) }

  let(:object) { Object.new.extend(described_class) }
  let(:node)   { described_class::N_TRUE            }

  it 'returns the negated node' do
    expect(subject).to eq(parse('not true'))
  end
end
