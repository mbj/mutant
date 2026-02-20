# frozen_string_literal: true

RSpec.describe Mutant::Expression::Method do
  let(:object)           { parse_expression(input)   }
  let(:env)              { Fixtures::TEST_ENV        }
  let(:instance_method)  { 'TestApp::Literal#string' }
  let(:singleton_method) { 'TestApp::Literal.string' }

  describe '#match_length' do
    let(:input) { instance_method }

    subject { object.match_length(other) }

    context 'when other is an equivalent expression' do
      let(:other) { parse_expression(object.syntax) }

      it { is_expected.to be(object.syntax.length) }
    end

    context 'when other is an unequivalent expression' do
      let(:other) { parse_expression('Foo*') }

      it { is_expected.to be(0) }
    end
  end

  describe '#matcher' do
    subject { object.matcher(env: instance_double(Mutant::Env)) }

    context 'with an instance method' do
      let(:input) { instance_method }

      it 'uses expected scope' do
        expect(subject.matcher.matchers.map(&:scope)).to eql(
          [
            Mutant::Scope.new(
              expression: Mutant::Expression::Namespace::Exact.new(scope_name: 'TestApp::Literal'),
              raw:        TestApp::Literal
            )
          ]
        )
      end

      it 'returns correct matcher' do
        expect(subject.call(env).map(&:expression)).to eql([object])
      end
    end

    context 'with a singleton method' do
      let(:input) { singleton_method }

      it 'returns correct matcher' do
        expect(subject.call(env).map(&:expression)).to eql([object])
      end
    end
  end

  describe '#syntax' do
    subject { object.syntax }

    context 'on instance method' do
      let(:input) { instance_method }

      it { is_expected.to eql(instance_method) }

      its(:frozen?) { is_expected.to be(true) }
    end

    context 'on singleton method' do
      let(:input) { singleton_method }

      it { is_expected.to eql(singleton_method) }

      its(:frozen?) { is_expected.to be(true) }
    end
  end

  describe '.try_parse' do
    def apply
      described_class.try_parse(input)
    end

    %w[λ a foo bar _bar a? ! + - <=>].each do |valid|
      context "with method name #{valid.inspect}" do
        let(:input) { "SomeClass##{valid}" }

        it 'returns expected instance' do
          expect(apply)
            .to eql(
              described_class.new(
                method_name:  valid,
                scope_name:   'SomeClass',
                scope_symbol: '#'
              )
            )
        end
      end
    end

    (%w[0 1 . foo()] + ['', ' ', "\n", "\0", "foo\nbar"]).each do |invalid|
      context "with method name #{invalid.inspect}" do
        let(:input) { "SomeClass##{invalid}" }

        it 'returns nil' do
          expect(apply).to be(nil)
        end
      end

    end
  end
end
