# frozen_string_literal: true

RSpec.describe Mutant::Subject::Method::Instance do
  let(:object) do
    described_class.new(
      config:     Mutant::Subject::Config::DEFAULT,
      context:,
      node:,
      visibility: :private
    )
  end

  let(:node) { Unparser.parse('def foo; end') }

  let(:constant_scope) do
    Mutant::Context::ConstantScope::None.new
  end

  let(:context) do
    Mutant::Context.new(
      constant_scope:,
      scope:,
      source_path:    instance_double(Pathname)
    )
  end

  let(:scope) do
    Mutant::Scope.new(
      expression: instance_double(Mutant::Expression),
      raw:        Class.new do
        attr_reader :bar

        def initialize
          @bar = :boo
        end

        def foo; end

        def self.name
          'Test'
        end
      end
    )
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
    subject { object.prepare }

    it 'undefines method on scope' do
      expect { subject }
        .to change { scope.raw.instance_methods.include?(:foo) }
        .from(true)
        .to(false)
    end

    it_should_behave_like 'a command method'
  end

  describe '#post_insert' do
    subject { object.post_insert }

    it 'sets method visibility' do
      expect { subject }
        .to change { scope.raw.private_instance_methods.include?(:foo) }
        .from(false)
        .to(true)
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
      config:     Mutant::Subject::Config::DEFAULT,
      context:,
      node:,
      visibility: :public
    )
  end

  let(:constant_scope) do
    Mutant::Context::ConstantScope::None.new
  end

  let(:context) do
    Mutant::Context.new(
      constant_scope:,
      scope:,
      source_path:    instance_double(Pathname)
    )
  end

  let(:node) { Unparser.parse('def foo; end') }

  shared_context 'memoizable scope setup' do
    let(:scope) do
      Mutant::Scope.new(
        expression: instance_double(Mutant::Expression),
        raw:        Class.new do
          include Unparser::Adamantium

          def self.name
            'MemoizableClass'
          end

          def foo; end
          memoize :foo
        end
      )
    end
  end

  describe '#prepare' do
    include_context 'memoizable scope setup'

    subject { object.prepare }

    it 'undefines memoizer' do
      expect { subject }.to change { scope.raw.memoized?(:foo) }.from(true).to(false)
    end

    it 'undefines method on scope' do
      expect { subject }.to change { scope.raw.instance_methods.include?(:foo) }.from(true).to(false)
    end

    it_should_behave_like 'a command method'
  end

  describe '#mutations' do
    subject { object.mutations }

    let(:expected) do
      [
        Mutant::Mutation::Neutral.from_node(
          subject: object,
          node:    s(:begin, s(:def, :foo, s(:args), nil), memoize_node)
        ),
        Mutant::Mutation::Evil.from_node(
          subject: object,
          node:    s(:begin, s(:def, :foo, s(:args), s(:send, nil, :raise)), memoize_node)
        ),
        Mutant::Mutation::Evil.from_node(
          subject: object,
          node:    s(:begin, s(:def, :foo, s(:args), s(:zsuper)), memoize_node)
        )
      ].map(&:from_right)
    end

    let(:memoize_node) do
      s(:send, nil, :memoize, s(:sym, :foo))
    end

    context 'when Memoizable is included in scope' do
      include_context 'memoizable scope setup'

      it { should eql(expected) }
    end
  end

  describe '#source' do
    subject { object.source }

    context 'when Memoizable is included in scope' do
      include_context 'memoizable scope setup'

      let(:source) { "def foo\nend\nmemoize(:foo)\n" }

      it { should eql(source) }
    end
  end
end
