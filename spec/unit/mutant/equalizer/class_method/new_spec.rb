# encoding: utf-8

require 'spec_helper'

describe Mutant::Equalizer, '.new' do
  let(:object) { described_class }
  let(:name)   { 'User'          }
  let(:klass)  { ::Class.new     }

  context 'with no keys' do
    subject { object.new }

    before do
      # specify the class #name method
      klass.stub(:name).and_return(name)
      klass.send(:include, subject)
    end

    let(:instance) { klass.new }

    it { should be_instance_of(object) }

    it 'defines #hash and #inspect methods dynamically' do
      subject.public_instance_methods(false).map(&:to_s).should =~ %w[ hash inspect ]
    end

    describe '#eql?' do
      context 'when the objects are similar' do
        let(:other) { instance.dup }

        it { instance.eql?(other).should be(true) }
      end

      context 'when the objects are different' do
        let(:other) { stub('other') }

        it { instance.eql?(other).should be(false) }
      end
    end

    describe '#==' do
      context 'when the objects are similar' do
        let(:other) { instance.dup }

        it { (instance == other).should be(true) }
      end

      context 'when the objects are different' do
        let(:other) { stub('other') }

        it { (instance == other).should be(false) }
      end
    end

    describe '#hash' do
      it { instance.hash.should eql(klass.hash) }

      it 'memoizes the hash code' do
        instance.hash.should eql(instance.memoized(:hash))
      end
    end

    describe '#inspect' do
      it { instance.inspect.should eql('#<User>') }
    end
  end

  context 'with keys' do
    subject { object.new(*keys) }

    let(:keys)       { [ :first_name ].freeze }
    let(:first_name) { 'John'                 }
    let(:instance)   { klass.new(first_name)  }

    let(:klass) do
      ::Class.new do
        attr_reader :first_name

        def initialize(first_name)
          @first_name = first_name
        end
      end
    end

    before do
      # specify the class #inspect method
      klass.stub(:name).and_return(nil)
      klass.stub(:inspect).and_return(name)
      klass.send(:include, subject)
    end

    it { should be_instance_of(object) }

    it 'defines #hash and #inspect methods dynamically' do
      subject.public_instance_methods(false).map(&:to_s).should =~ %w[ hash inspect ]
    end

    describe '#eql?' do
      context 'when the objects are similar' do
        let(:other) { instance.dup }

        it { instance.eql?(other).should be(true) }
      end

      context 'when the objects are different' do
        let(:other) { stub('other') }

        it { instance.eql?(other).should be(false) }
      end
    end

    describe '#==' do
      context 'when the objects are similar' do
        let(:other) { instance.dup }

        it { (instance == other).should be(true) }
      end

      context 'when the objects are different' do
        let(:other) { stub('other') }

        it { (instance == other).should be(false) }
      end
    end

    describe '#hash' do
      it { instance.hash.should eql(klass.hash ^ first_name.hash) }

      it 'memoizes the hash code' do
        instance.hash.should eql(instance.memoized(:hash))
      end
    end

    describe '#inspect' do
      it { instance.inspect.should eql('#<User first_name="John">') }
    end
  end
end
