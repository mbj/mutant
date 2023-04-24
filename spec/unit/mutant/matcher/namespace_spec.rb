# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Namespace, '#call' do
  let(:object)      { described_class.new(expression: parse_expression('TestApp*')) }
  let(:env)         { instance_double(Mutant::Env)                                  }
  let(:raw_scope_a) { instance_double(Class, name: 'TestApp::Literal')              }
  let(:raw_scope_b) { instance_double(Class, name: 'TestApp::Foo')                  }
  let(:raw_scope_c) { instance_double(Class, name: 'TestAppOther')                  }
  let(:subject_a)   { instance_double(Mutant::Subject)                              }
  let(:subject_b)   { instance_double(Mutant::Subject)                              }

  before do
    [
      [Mutant::Matcher::Methods::Singleton, raw_scope_b, [subject_b]],
      [Mutant::Matcher::Methods::Instance,  raw_scope_b, []],
      [Mutant::Matcher::Methods::Metaclass, raw_scope_b, []],
      [Mutant::Matcher::Methods::Singleton, raw_scope_a, [subject_a]],
      [Mutant::Matcher::Methods::Instance,  raw_scope_a, []],
      [Mutant::Matcher::Methods::Metaclass, raw_scope_a, []]
    ].each do |klass, scope, subjects|
      matcher = instance_double(Mutant::Matcher)
      expect(matcher).to receive(:call).with(env).and_return(subjects)

      expect(klass).to receive(:new)
        .with(scope: scope)
        .and_return(matcher)
    end

    allow(env).to receive(:matchable_scopes).and_return(
      [raw_scope_a, raw_scope_b, raw_scope_c].map do |raw_scope|
        Mutant::Scope.new(raw: raw_scope, expression: parse_expression(raw_scope.name))
      end
    )
  end

  it 'returns subjects' do
    expect(object.call(env)).to eql([subject_a, subject_b])
  end
end
