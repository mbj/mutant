RSpec.describe Mutant::Subject::Method::Instance do
  let(:object)  { described_class.new(config, context, node) }
  let(:context) { Mutant::Context::Scope.new(scope, double('Source Path')) }
  let(:config)  { Mutant::Config::DEFAULT }

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

  describe '#prepare' do

    let(:context) do
      Mutant::Context::Scope.new(scope, double('Source Path'))
    end

    subject { object.prepare }

    context 'on non initialize methods' do

      it 'undefines method on scope' do
        expect { subject }.to change { scope.instance_methods.include?(:foo) }.from(true).to(false)
      end

      it_should_behave_like 'a command method'

    end

    context 'on initialize method' do

      let(:node) do
        s(:def, :initialize, s(:args))
      end

      it 'does not write warnings' do
        warnings = Mutant::WarningFilter.use do
          subject
        end
        expect(warnings).to eql([])
      end

      it 'undefines method on scope' do
        subject
        expect { scope.new }.to raise_error(NoMethodError)
      end

      it_should_behave_like 'a command method'
    end
  end

  describe '#source' do
    subject { object.source }

    it { should eql("def foo\nend") }
  end
end

RSpec.describe Mutant::Subject::Method::Instance::Memoized do
  let(:object)  { described_class.new(config, context, node) }
  let(:context) { double                                     }
  let(:config)  { Mutant::Config::DEFAULT                    }

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

  describe '#source' do
    subject { object.source }

    it { should eql("def foo\nend\nmemoize(:foo)") }
  end
end
