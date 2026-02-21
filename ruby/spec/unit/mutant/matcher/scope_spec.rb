# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Scope, '#call' do
  let(:object)    { described_class.new(scope:) }
  let(:env)       { instance_double(Mutant::Env)      }
  let(:matcher_a) { instance_double(Mutant::Matcher)  }
  let(:matcher_b) { instance_double(Mutant::Matcher)  }
  let(:matcher_c) { instance_double(Mutant::Matcher)  }
  let(:subject_a) { instance_double(Mutant::Subject)  }
  let(:subject_b) { instance_double(Mutant::Subject)  }
  let(:subject_c) { instance_double(Mutant::Subject)  }

  let(:scope) do
    Mutant::Scope.new(
      expression: instance_double(Mutant::Expression),
      raw:        TestApp
    )
  end

  subject { object.call(env) }

  before do
    expect(Mutant::Matcher::Methods::Singleton).to receive(:new)
      .with(scope:)
      .and_return(matcher_a)

    expect(Mutant::Matcher::Methods::Instance).to receive(:new)
      .with(scope:)
      .and_return(matcher_b)

    expect(Mutant::Matcher::Methods::Metaclass).to receive(:new)
      .with(scope:)
      .and_return(matcher_c)

    expect(matcher_a).to receive(:call)
      .with(env)
      .and_return([subject_a])

    expect(matcher_b).to receive(:call)
      .with(env)
      .and_return([subject_b])

    expect(matcher_c).to receive(:call)
      .with(env)
      .and_return([subject_c])
  end

  it 'concatenates subjects from matched singleton and instance methods' do
    is_expected.to eql([subject_a, subject_b, subject_c])
  end
end
