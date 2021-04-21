# frozen_string_literal: true

RSpec.describe Mutant::Subject::Method::Singleton do
  let(:object) do
    described_class.new(
      context: context,
      node:    node
    )
  end

  let(:node) { s(:defs, s(:self), :foo, s(:args)) }

  let(:context) do
    Mutant::Context.new(scope, instance_double(Pathname))
  end

  let(:scope) do
    Class.new do
      def self.foo; end

      def self.name
        'Test'
      end
    end
  end

  describe '#expression' do
    subject { object.expression }

    it { should eql(parse_expression('Test.foo')) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#match_expression' do
    subject { object.match_expressions }

    it { should eql(%w[Test.foo Test*].map(&method(:parse_expression))) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#prepare' do

    subject { object.prepare }

    it 'undefines method on scope' do
      expect { subject }.to change { scope.public_methods.include?(:foo) }.from(true).to(false)
    end

    it_should_behave_like 'a command method'
  end

  describe '#source' do
    subject { object.source }

    it { should eql("def self.foo\nend") }
  end
end
