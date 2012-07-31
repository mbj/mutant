require 'spec_helper'

describe Mutant::Context::Constant, '.build' do
  subject { described_class.build(constant) }

  let(:object) { described_class }
  let(:context) { mock('Context') }

  before do
    described_class.stub(:new => context)
  end

  context 'when constant is a module' do
    let(:constant) { Module.new }

    it 'should initialize context correctly' do
      described_class.should_receive(:new).with(constant, 'module', Rubinius::AST::ModuleScope).and_return(context)
      should be(context)
    end

    it { should be(context) }
  end

  context 'when constant is a class' do
    let(:constant) { Class.new }

    it 'should initialize context correctly' do
      described_class.should_receive(:new).with(constant, 'class', Rubinius::AST::ClassScope).and_return(context)
      should be(context)
    end

    it { should be(context) }
  end

  context 'when constant is not a class nor a module' do
    let(:constant) { Object.new }

    it 'should raise error' do
      expect { subject }.to raise_error(ArgumentError, 'Can only build constant mutation scope from class or module')
    end
  end
end
