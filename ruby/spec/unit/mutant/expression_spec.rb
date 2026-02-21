# frozen_string_literal: true

RSpec.describe Mutant::Expression do
  describe '#prefix?' do
    let(:object) { parse_expression('Foo*') }

    subject { object.prefix?(other) }

    context 'when object is a prefix of other' do
      let(:other) { parse_expression('Foo::Bar') }

      it { is_expected.to be(true) }
    end

    context 'when other is not a prefix of other' do
      let(:other) { parse_expression('Bar') }

      it { is_expected.to be(false) }
    end
  end

  describe '#frozen?' do
    subject { parse_expression('Foo').frozen? }

    it { is_expected.to be(true) }
  end

  describe '.try_parse' do
    let(:object) do
      Class.new(described_class) do
        include Unparser::Anima.new(:foo)

        const_set(:REGEXP, /(?<foo>foo)/)
      end
    end

    subject { object.try_parse(input) }

    context 'good input' do
      let(:input) { 'foo' }

      it { is_expected.to eql(object.new(foo: 'foo')) }
    end

    context 'bad input' do
      let(:input) { 'bar' }

      it { is_expected.to be(nil) }
    end
  end
end
