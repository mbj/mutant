# encoding: utf-8

require 'spec_helper'

filter_helpers = proc do
  let(:input_a) { double('Input A', foo: 'bar') }
  let(:input_b) { double('Input B', foo: 'baz') }

  let(:filter_a) do
    input_a = self.input_a
    Module.new do
      define_singleton_method(:match?) do |input|
        input == input_a
      end
    end
  end

  subject { object.match?(input) }
end

describe Mutant::Predicate::Whitelist do
  instance_eval(&filter_helpers)

  let(:object) { described_class.new(whitelist) }

  describe '#match?' do

    context 'with empty whitelist' do
      let(:whitelist) { [] }

      it 'accepts all inputs' do
        expect(object.match?(input_a)).to be(false)
        expect(object.match?(input_b)).to be(false)
      end
    end

    context 'with non empty whitelist' do
      let(:whitelist) { [filter_a] }

      context 'with whitelisted input' do
        let(:input) { input_a }

        it { should be(true) }
      end

      context 'with non whitelisted input' do
        let(:input) { input_b }

        it { should be(false) }
      end
    end
  end
end

describe Mutant::Predicate::Blacklist do
  instance_eval(&filter_helpers)

  let(:object) { described_class.new(whitelist) }

  describe '#match?' do

    context 'with empty whitelist' do
      let(:whitelist) { [] }

      it 'accepts all inputs' do
        expect(object.match?(input_a)).to be(true)
        expect(object.match?(input_b)).to be(true)
      end
    end

    context 'with non empty whitelist' do
      let(:whitelist) { [filter_a] }

      context 'with whitelisted input' do
        let(:input) { input_a }

        it { should be(false) }
      end

      context 'with non whitelisted input' do
        let(:input) { input_b }

        it { should be(true) }
      end
    end
  end
end

describe Mutant::Predicate::Attribute::Equality do
  instance_eval(&filter_helpers)

  let(:object) { described_class.new(attribute_name, expected_value) }
  let(:input)   { double('Input', attribute_name => actual_value)      }

  let(:attribute_name) { :foo    }
  let(:expected_value) { 'value' }

  describe '#match?' do

    context 'not matching' do
      let(:actual_value) { 'other-value' }
      it { should be(false) }
    end

    context 'matching' do
      let(:actual_value) { 'value' }
      it { should be(true) }
    end

  end
end

describe Mutant::Predicate::Attribute::Regexp do
  instance_eval(&filter_helpers)

  let(:object) { described_class.new(attribute_name, expectation) }
  let(:input)   { double('Input', attribute_name => actual_value)   }

  let(:attribute_name) { :foo    }
  let(:expectation)    { /\Avalue\z/ }

  describe '#match?' do

    context 'not matching' do
      let(:actual_value) { 'other-value' }
      it { should be(false) }
    end

    context 'matching' do
      let(:actual_value) { 'value' }
      it { should be(true) }
    end

  end
end
