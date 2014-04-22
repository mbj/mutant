# encoding: UTF-8

require 'spec_helper'

describe Mutant::Subject::Method::Instance do
  include Mutant::NodeHelpers

  let(:object)  { described_class.new(context, node) }
  let(:context) { double }

  let(:node) do
    s(:def, :foo, s(:args))
  end

  describe '#prepare' do

    let(:context) do
      Mutant::Context::Scope.new(scope, double('Source Path'))
    end

    let(:scope) do
      Class.new do
        attr_reader :bar

        def initialize
          @bar = :boo
        end

        def foo
        end
      end
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

describe Mutant::Subject::Method::Instance::Memoized do
  include Mutant::NodeHelpers

  let(:object)  { described_class.new(context, node) }
  let(:context) { double }

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
