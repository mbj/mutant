# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Method.const_get(:Evaluator), '#source_location' do
  subject { object.__send__(:source_location) }

  let(:object) { Class.new(described_class).new(scope: nil, target_method:, env: nil) }
  let(:target_method) { owner.instance_method(:foo).super_method }
  let(:receiver) { owner.new }

  let(:owner) do
    Class.new do
      extend T::Sig

      sig { returns(Integer) }
      def foo
        42
      end
    end
  end

  let(:wrapper) do
    Module.new do
      def foo
        @foo ||= super
      end
    end
  end

  before do
    owner.prepend(wrapper)
  end

  it 'resolves the implementation behind a signed prepended method' do
    expect(subject.first).to eql(__FILE__)
  end

  it 'keeps the prepended wrapper installed' do
    subject

    expect(owner.instance_method(:foo).owner).to be(wrapper)
    expect(receiver.foo).to be(42)
  end

  context 'when the signature has already been resolved' do
    before { receiver.foo }

    it 'resolves the implementation' do
      expect(subject.first).to eql(__FILE__)
    end
  end

  context 'with multiple prepended wrappers' do
    let(:target_method) { owner.instance_method(:foo).super_method.super_method }

    before do
      receiver.foo
      owner.prepend(Module.new do
        def foo
          super + 1
        end
      end)
    end

    it 'finds the signature registered on an inner wrapper' do
      expect(subject.first).to eql(__FILE__)
    end
  end

  context 'with a signed singleton method' do
    let(:owner) { receiver.singleton_class }

    let(:receiver) do
      Class.new do
        extend T::Sig

        sig { returns(Integer) }
        def self.foo
          42
        end
      end
    end

    it 'resolves the singleton implementation' do
      expect(subject.first).to eql(__FILE__)
    end
  end

  context 'when only the wrapper has a signature' do
    let(:owner) do
      Class.new do
        def foo
          42
        end
      end
    end

    let(:wrapper) do
      Module.new do
        extend T::Sig

        sig { returns(Integer) }
        def foo
          super + 1
        end
      end
    end

    it 'does not use the wrapper implementation as the subject' do
      expect(subject).to eql(target_method.source_location)
    end
  end
end
