# encoding: utf-8

require 'spec_helper'

describe Mutant::Equalizer::Methods, '#==' do
  subject { object == other }

  let(:object) { described_class.new(true) }

  let(:described_class) do
    Class.new do
      include Mutant::Equalizer::Methods

      attr_reader :boolean

      def initialize(boolean)
        @boolean = boolean
      end

      def cmp?(comparator, other)
        boolean.send(comparator, other.boolean)
      end
    end
  end

  context 'with the same object' do
    let(:other) { object }

    it { should be(true) }

    it 'is symmetric' do
      should eql(other == object)
    end
  end

  context 'with an equivalent object' do
    let(:other) { object.dup }

    it { should be(true) }

    it 'is symmetric' do
      should eql(other == object)
    end
  end

  context 'with an equivalent object of a subclass' do
    let(:other) { Class.new(described_class).new(true) }

    it { should be(true) }

    it 'is symmetric' do
      should eql(other == object)
    end
  end

  context 'with an object of another class' do
    let(:other) { Class.new.new }

    it { should be(false) }

    it 'is symmetric' do
      should eql(other == object)
    end
  end

  context 'with an equivalent object after coercion' do
    let(:other) { Object.new }

    before do
      # declare a private #coerce method
      described_class.class_eval do
        def coerce(other)
          self.class.new(!!other)
        end
        private :coerce
      end
    end

    it { should be(true) }

    it 'is not symmetric' do
      should_not eql(other == object)
    end
  end
end
