# frozen_string_literal: true

RSpec.describe Mutant::Subject::Method::Instance do
  let(:object)  { described_class.new(context, node) }

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

    it_should_behave_like 'a command method'
  end

  describe '#source' do
    subject { object.source }

    specify do
      should eql(<<~'RUBY'.chomp)
        def foo
        end
      RUBY
    end
  end
end

RSpec.describe Mutant::Subject::Method::Instance::Memoized do
  let(:object)  { described_class.new(context, node) }
  let(:context) { instance_double(Mutant::Context)   }
  let(:node)    { s(:def, :foo, s(:args))            }

  describe '#prepare' do
    let(:context) do
      Mutant::Context.new(scope, instance_double(Array))
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
      expect { subject }
        .to change { scope.memoized?(:foo) }
        .from(true)
        .to(false)
    end

    it 'undefines method on scope' do
      expect { subject }
        .to change { scope.instance_methods.include?(:foo) }
        .from(true)
        .to(false)
    end

    it_should_behave_like 'a command method'
  end

  describe '#mutations', mutant_expression: 'Mutant::Subject#mutations' do
    subject { object.mutations }

    let(:memoize) { s(:send, nil, :memoize, s(:args, s(:sym, :foo))) }

    let(:expected) do
      [
        Mutant::Mutation::Neutral.new(
          object,
          s(:begin, s(:def, :foo, s(:args)), memoize)
        ),
        Mutant::Mutation::Evil.new(
          object,
          s(:begin, s(:def, :foo, s(:args), s(:send, nil, :raise)), memoize)
        ),
        Mutant::Mutation::Evil.new(
          object,
          s(:begin, s(:def, :foo, s(:args), s(:zsuper)), memoize)
        ),
        Mutant::Mutation::Evil.new(
          object,
          s(:begin, s(:def, :foo, s(:args), nil), memoize)
        )
      ]
    end

    it { should eql(expected) }
  end

  describe '#source' do
    subject { object.source }

    specify do
      should eql(<<~'RUBY'.chomp)
        def foo
        end
        memoize(:foo)
      RUBY
    end
  end
end
