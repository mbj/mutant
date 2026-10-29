# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Method, '.own_method' do
  def apply
    described_class.own_method(method, owner)
  end

  let(:wrapper) do
    Module.new do
      def foo; end
    end
  end

  let(:owner) do
    wrapper = wrapper()

    Class.new do
      prepend wrapper

      def foo; end
    end
  end

  context 'when the method is owned by the module' do
    let(:method) { owner.instance_method(:foo).super_method }

    it 'returns the method' do
      expect(apply).to eql(method)
    end
  end

  context 'when a prepended module wraps the method' do
    let(:method) { owner.instance_method(:foo) }

    it 'returns the method owned by the module' do
      expect(apply).to eql(method.super_method)
    end
  end

  context 'when the module does not define the method' do
    let(:method) { wrapper.instance_method(:foo) }

    it 'returns nil' do
      expect(apply).to be(nil)
    end
  end
end
