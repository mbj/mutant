# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Filter, '#call' do
  subject { object.call(env) }

  let(:object)    { described_class.new(matcher, predicate) }
  let(:matcher)   { instance_double(Mutant::Matcher)        }
  let(:subject_a) { instance_double(Mutant::Subject)        }
  let(:subject_b) { instance_double(Mutant::Subject)        }
  let(:env)       { instance_double(Mutant::Env)            }
  let(:predicate) { ->(node) { node.eql?(subject_a) }       }

  before do
    expect(matcher).to receive(:call)
      .with(env)
      .and_return([subject_a, subject_b])
  end

  it 'returns subjects after filtering' do
    should eql([subject_a])
  end
end
