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
  let(:node)        { Unparser.parse('def foo; end')    }
  let(:warnings)    { instance_double(Mutant::Warnings) }

  let(:context) do
    Mutant::Context.new(
      scope,
      instance_double(Pathname)
    )
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

  let(:context)  { Mutant::Context.new(scope, double('Source Path')) }
  let(:node)     { Unparser.parse('def foo; end')                    }
  let(:warnings) { instance_double(Mutant::Warnings)                 }

  before do
    allow(warnings).to receive(:call).and_yield

    allow(Object).to receive_messages(const_get: scope)
  end

  shared_context 'memoizable scope setup' do
    let(:scope) do
      Class.new do
        include Memoizable

        def self.name
          'MemoizableClass'
        end

        def foo; end
        memoize :foo
      end
    end
  end

  shared_context 'adamantium scope setup' do
    let(:scope) do
      memoize_options  = self.memoize_options
      memoize_provider = self.memoize_provider

      Class.new do
        include memoize_provider

        def self.name
          'AdamantiumClass'
        end

        def foo; end
        memoize :foo, **memoize_options
      end
    end
  end

  describe '#prepare' do
    include_context 'memoizable scope setup'

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

    let(:options_node) { nil }

    let(:expected) do
      [
        Mutant::Mutation::Neutral.new(
          object,
          s(:begin, s(:def, :foo, s(:args), nil), memoize_node)
        ),
        Mutant::Mutation::Evil.new(
          object,
          s(:begin, s(:def, :foo, s(:args), s(:send, nil, :raise)), memoize_node)
        ),
        Mutant::Mutation::Evil.new(
          object,
          s(:begin, s(:def, :foo, s(:args), s(:zsuper)), memoize_node)
        )
      ]
    end

    let(:memoize_node) do
      s(:send, nil, :memoize, s(:sym, :foo), *options_node)
    end

    context 'when Memoizable is included in scope' do
      include_context 'memoizable scope setup'

      it { should eql(expected) }
    end

    context 'when Adamantium is included in scope' do
      include_context 'adamantium scope setup'

      {
        Adamantium       => :deep,
        Adamantium::Flat => :flat
      }.each do |memoize_provider, default_freezer_option|
        context "as include #{memoize_provider}" do
          let(:memoize_provider) { memoize_provider }

          let(:options_node) do
            [s(:kwargs, s(:pair, s(:sym, :freezer), s(:sym, freezer_option)))]
          end

          context 'when no memoize options are given' do
            let(:memoize_options) { Mutant::EMPTY_HASH     }
            let(:freezer_option)  { default_freezer_option }

            it { should eql(expected) }
          end

          context 'when memoize options are given' do
            let(:memoize_options) { { freezer: freezer_option } }

            %i[deep flat noop].each do |option|
              context "as #{option.inspect}" do
                let(:freezer_option) { option }

                it { should eql(expected) }
              end
            end
          end
        end
      end
    end
  end

  describe '#source' do
    subject { object.source }

    context 'when Memoizable is included in scope' do
      include_context 'memoizable scope setup'

      let(:source) { "def foo\nend\nmemoize(:foo)\n" }

      it { should eql(source) }
    end

    context 'when Adamantium is included in scope' do
      include_context 'adamantium scope setup'

      let(:source) do
        "def foo\nend\nmemoize(:foo, freezer: #{freezer_option.inspect})\n"
      end

      {
        Adamantium       => :deep,
        Adamantium::Flat => :flat
      }.each do |memoize_provider, default_freezer_option|
        context "as include #{memoize_provider}" do
          let(:memoize_provider) { memoize_provider }

          context 'when no memoize options are given' do
            let(:memoize_options) { Mutant::EMPTY_HASH     }
            let(:freezer_option)  { default_freezer_option }

            it { should eql(source) }
          end

          context 'when memoize options are given' do
            %i[deep flat noop].each do |freezer_option|
              context "as #{freezer_option.inspect}" do
                let(:memoize_options) { { freezer: freezer_option } }
                let(:freezer_option)  { freezer_option              }

                it { should eql(source) }
              end
            end
          end
        end
      end
    end
  end
end
