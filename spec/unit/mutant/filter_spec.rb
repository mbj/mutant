require 'spec_helper'

filter_helpers = proc do
  let(:item_a) { double('Item A', :foo => 'bar') }
  let(:item_b) { double('Item B', :foo => 'baz') }

  let(:filter_a) do
    item_a = self.item_a
    Module.new do
      define_singleton_method(:match?) do |item|
        item == item_a
      end
    end
  end

  subject { object.match?(item) }
end

describe Mutant::Filter::Whitelist do
  instance_eval(&filter_helpers)

  let(:object) { described_class.new(whitelist) }

  describe '#match?' do

    context 'with empty whitelist' do
      let(:whitelist) { [] }

      it 'accepts all items' do
        expect(object.match?(item_a)).to be(false)
        expect(object.match?(item_b)).to be(false)
      end
    end

    context 'with non empty whitelist' do
      let(:whitelist) { [filter_a] }

      context 'with whitelisted item' do
        let(:item) { item_a }

        it { should be(true) }
      end

      context 'with non whitelisted item' do
        let(:item) { item_b }

        it { should be(false) }
      end
    end
  end
end

describe Mutant::Filter::Blacklist do
  instance_eval(&filter_helpers)

  let(:object) { described_class.new(whitelist) }

  describe '#match?' do

    context 'with empty whitelist' do
      let(:whitelist) { [] }

      it 'accepts all items' do
        expect(object.match?(item_a)).to be(true)
        expect(object.match?(item_b)).to be(true)
      end
    end

    context 'with non empty whitelist' do
      let(:whitelist) { [filter_a] }

      context 'with whitelisted item' do
        let(:item) { item_a }

        it { should be(false) }
      end

      context 'with non whitelisted item' do
        let(:item) { item_b }

        it { should be(true) }
      end
    end
  end
end

describe Mutant::Filter::Attribute::Equality do
  instance_eval(&filter_helpers)

  let(:object) { described_class.new(attribute_name, expected_value) }
  let(:item)   { double('Item', attribute_name => actual_value)      }

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

describe Mutant::Filter::Attribute::Regexp do
  instance_eval(&filter_helpers)

  let(:object) { described_class.new(attribute_name, expectation) }
  let(:item)   { double('Item', attribute_name => actual_value)   }

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
