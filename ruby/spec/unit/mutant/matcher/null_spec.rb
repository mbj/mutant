# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Null, '#call' do
  let(:object) { described_class.new          }
  let(:env)    { instance_double(Mutant::Env) }

  subject { object.call(env) }

  it 'returns no subjects' do
    should eql([])
  end
end
