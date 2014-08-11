RSpec.describe Mutant::Subject::Method::Singleton do

  let(:object)  { described_class.new(config, context, node) }
  let(:config)  { Mutant::Config::DEFAULT                    }
  let(:node)    { s(:defs, s(:self), :foo, s(:args))         }

  let(:context) do
    Mutant::Context::Scope.new(scope, double('Source Path'))
  end

  let(:scope) do
    Class.new do
      def self.foo
      end

      def self.name
        'Test'
      end
    end
  end

  describe '#expression' do
    subject { object.expression }

    it { should eql(Mutant::Expression.parse('Test.foo')) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#prepare' do

    subject { object.prepare }

    it 'undefines method on scope' do
      expect { subject }.to change { scope.methods.include?(:foo) }.from(true).to(false)
    end

    it_should_behave_like 'a command method'
  end

  describe '#source' do
    subject { object.source }

    it { should eql("def self.foo\nend") }
  end

  describe '#public?' do
    subject { object.public? }

    context 'when method is public' do
      it { should be(true) }
    end

    context 'when method is private' do
      before do
        scope.class_eval do
          private_class_method :foo
        end
      end

      it { should be(false) }
    end

    context 'when method is protected' do
      before do
        class << scope
          protected :foo
        end
      end

      it { should be(false) }
    end
  end
end
