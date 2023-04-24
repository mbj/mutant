# frozen_string_literal: true

RSpec.describe Mutant::Expression::Methods do
  let(:object) { described_class.new(attributes) }

  describe '#match_length' do
    let(:attributes) { { scope_name: 'TestApp::Literal', scope_symbol: '#' } }

    subject { object.match_length(other) }

    context 'when other is an equivalent expression' do
      let(:other) { parse_expression(object.syntax) }

      it { should be(object.syntax.length) }
    end

    context 'when other is matched' do
      let(:other) { parse_expression('TestApp::Literal#foo') }

      it { should be(object.syntax.length) }
    end

    context 'when other is an not matched expression' do
      let(:other) { parse_expression('Foo*') }

      it { should be(0) }
    end
  end

  describe '#syntax' do
    subject { object.syntax }

    context 'with an instance method' do
      let(:attributes) { { scope_name: 'TestApp::Literal', scope_symbol: '#' } }

      it { should eql('TestApp::Literal#') }

      its(:frozen?) { should be(true) }
    end

    context 'with a singleton method' do
      let(:attributes) { { scope_name: 'TestApp::Literal', scope_symbol: '.' } }

      it { should eql('TestApp::Literal.') }

      its(:frozen?) { should be(true) }
    end
  end

  describe '#matcher' do
    subject { object.matcher }

    context 'with an instance method' do
      let(:attributes) { { scope_name: 'TestApp::Literal', scope_symbol: '#' } }

      specify do
        should eql(
          Mutant::Matcher::Chain.new(
            matchers: [Mutant::Matcher::Methods::Instance.new(scope: TestApp::Literal)]
          )
        )
      end
    end

    context 'with a singleton method' do
      let(:attributes) { { scope_name: 'TestApp::Literal', scope_symbol: '.' } }

      it do
        should eql(
          Mutant::Matcher::Chain.new(
            matchers: [
              Mutant::Matcher::Methods::Singleton.new(scope: TestApp::Literal),
              Mutant::Matcher::Methods::Metaclass.new(scope: TestApp::Literal)
            ]
          )
        )
      end
    end
  end
end
