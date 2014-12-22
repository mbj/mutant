RSpec.describe Mutant::Subject::Method::Instance do
  let(:object)  { described_class.new(context, node)                       }
  let(:context) { Mutant::Context::Scope.new(scope, double('Source Path')) }

  let(:node) do
    s(:def, :foo, s(:args))
  end

  let(:scope) do
    Class.new do
      attr_reader :bar

      def initialize
        @bar = :boo
      end

      def foo
      end

      def self.name
        'Test'
      end
    end
  end

  describe '#expression' do
    subject { object.expression }

    it { should eql(Mutant::Expression.parse('Test#foo')) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#match_expression' do
    subject { object.match_expressions }

    it { should eql(%w[Test#foo Test*].map(&Mutant::Expression.method(:parse))) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#prepare' do

    let(:context) do
      Mutant::Context::Scope.new(scope, double('Source Path'))
    end

    subject { object.prepare }

    it 'undefines method on scope' do
      expect { subject }.to change { scope.instance_methods.include?(:foo) }.from(true).to(false)
    end

    it_should_behave_like 'a command method'
  end

  describe '#source' do
    subject { object.source }

    it { should eql("def foo\nend") }
  end

  describe '#public?' do
    subject { object.public? }

    context 'when method is public' do
      it { should be(true) }
    end

    context 'when method is private' do
      before do
        scope.class_eval do
          private :foo
        end
      end

      it { should be(false) }
    end

    context 'when method is protected' do
      before do
        scope.class_eval do
          protected :foo
        end
      end

      it { should be(false) }
    end
  end
end

RSpec.describe Mutant::Subject::Method::Instance::Memoized do
  let(:object)  { described_class.new(context, node) }
  let(:context) { double('Context')                  }

  let(:node) do
    s(:def, :foo, s(:args))
  end

  describe '#prepare' do

    let(:context) do
      Mutant::Context::Scope.new(scope, double('Source Path'))
    end

    let(:scope) do
      Class.new do
        include Memoizable
        def foo
        end
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

  describe '#mutations' do
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
