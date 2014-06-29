# encoding: UTF-8

require 'spec_helper'

describe Mutant::Subject::Method::Singleton do

  let(:object)  { described_class.new(context, node) }
  let(:context) { double }

  let(:node) do
    s(:defs, s(:self), :foo, s(:args))
  end

  describe '#prepare' do

    let(:context) do
      Mutant::Context::Scope.new(scope, double('Source Path'))
    end

    let(:scope) do
      Class.new do
        def self.foo
        end
      end
    end

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
end
