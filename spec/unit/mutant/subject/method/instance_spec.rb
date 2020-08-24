# frozen_string_literal: true

RSpec.describe Mutant::Subject::Method::Instance do
  let(:object) do
    described_class.new(
      context:  context,
      node:     node,
      warnings: warnings
    )
  end

  let(:call_block?) { true                              }
  let(:warnings)    { instance_double(Mutant::Warnings) }

  let(:context) do
    Mutant::Context.new(
      scope,
      instance_double(Pathname)
    )
  end

  let(:node) do
    s(:def, :foo, s(:args))
  end

  let(:scope) do
    Class.new do
      attr_reader :bar

      def initialize
        @bar = :boo
      end

      def foo; end

      def self.name
        'Test'
      end
    end
  end

  before do
    allow(warnings).to receive(:call) do |&block|
      block.call if call_block?
    end
  end

  describe '#expression' do
    subject { object.expression }

    it { should eql(parse_expression('Test#foo')) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#match_expression' do
    subject { object.match_expressions }

    it { should eql(%w[Test#foo Test*].map(&method(:parse_expression))) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#prepare' do
    let(:context) do
      Mutant::Context.new(scope, instance_double(Pathname))
    end

    subject { object.prepare }

    it 'undefines method on scope' do
      expect { subject }
        .to change { scope.instance_methods.include?(:foo) }
        .from(true)
        .to(false)
    end

    context 'within warning capture' do
      let(:call_block?) { false }

      it 'undefines method on scope' do
        expect { subject }
          .to_not change { scope.instance_methods.include?(:foo) }
          .from(true)
      end
    end

    it_should_behave_like 'a command method'
  end

  describe '#source' do
    subject { object.source }

    it { should eql("def foo\nend") }
  end
end

RSpec.describe Mutant::Subject::Method::Instance::Memoized do
  let(:object) do
    described_class.new(
      context:  context,
      node:     node,
      warnings: warnings
    )
  end

  let(:context)  { double('Context')                 }
  let(:warnings) { instance_double(Mutant::Warnings) }

  let(:node) do
    s(:def, :foo, s(:args))
  end

  before do
    allow(warnings).to receive(:call).and_yield
  end

  describe '#prepare' do
    let(:context) do
      Mutant::Context.new(scope, double('Source Path'))
    end

    let(:scope) do
      Class.new do
        include Memoizable
        def foo; end
        memoize :foo
      end
    end

    subject { object.prepare }

    it 'undefines memoizer' do
      expect { subject }.to change { scope.memoized?(:foo) }.from(true).to(false)
    end

    it 'undefines method on scope' do
      expect { subject }.to change { scope.instance_methods.include?(:foo) }.from(true).to(false)
    end

    it_should_behave_like 'a command method'
  end

  describe '#mutations', mutant_expression: 'Mutant::Subject#mutations' do
    subject { object.mutations }

    let(:expected) do
      [
        Mutant::Mutation::Neutral.new(
          object,
          s(:begin,
            s(:def, :foo, s(:args)), s(:send, nil, :memoize, s(:args, s(:sym, :foo))))
        ),
        Mutant::Mutation::Evil.new(
          object,
          s(:begin,
            s(:def, :foo, s(:args), s(:send, nil, :raise)), s(:send, nil, :memoize, s(:args, s(:sym, :foo))))
        ),
        Mutant::Mutation::Evil.new(
          object,
          s(:begin,
            s(:def, :foo, s(:args), s(:zsuper)), s(:send, nil, :memoize, s(:args, s(:sym, :foo))))
        ),
        Mutant::Mutation::Evil.new(
          object,
          s(:begin,
            s(:def, :foo, s(:args), nil), s(:send, nil, :memoize, s(:args, s(:sym, :foo))))
        )
      ]
    end

    it { should eql(expected) }
  end

  describe '#source' do
    subject { object.source }

    it { should eql("def foo\nend\nmemoize(:foo)") }
  end
end
