require 'spec_helper'

# FIXME: This spec needs to be structured better!
describe Mutant::Mutator, 'send' do

  context 'with only a block arg' do
    let(:source) { 'foo(&bar)' }

    let(:mutations) do
      mutations = []
      mutations << 'foo'
    end
  end

  context 'with self as' do
    context 'implicit' do
      let(:source) { 'foo' }

      it_should_behave_like 'a noop mutator'
    end

    context 'explict receiver' do
      let(:source) { 'self.foo' }

      let(:mutations) do
        mutations = []
        mutations << 'foo'
        mutations << 'self'
      end

      it_should_behave_like 'a mutator'
    end

    context 'explicit receiver with keyword message name' do
      Unparser::Constants::KEYWORDS.each do |keyword|
        context "with keyword: #{keyword}" do
          let(:source) { "self.#{keyword}" }
          let(:mutations) do
            ['self']
          end
        end
      end
    end
  end

  context 'without arguments' do

    context 'to some object' do
      let(:source) { 'foo.bar' }

      let(:mutations) do
        mutations = []
        mutations << 'foo'
      end

      it_should_behave_like 'a mutator'
    end

    context 'to self.class.foo' do
      let(:source) { 'self.class.foo' }

      let(:mutations) do
        mutations = []
        mutations << 'self.class'
        mutations << 'self.foo'
      end

      it_should_behave_like 'a mutator'
    end
  end

  context 'with arguments' do

    context 'one argument' do
      let(:source) { 'foo(nil)' }

      let(:mutations) do
        mutations = []
        mutations << 'foo'
        mutations << 'nil'
        mutations << 'foo(::Object.new)'
      end

      it_should_behave_like 'a mutator'
    end

    context 'with explicit self as receiver' do
      let(:source) { 'self.foo(nil)' }

      let(:mutations) do
        mutations = []
        mutations << 'self'
        mutations << 'self.foo'
        mutations << 'foo(nil)'
        mutations << 'nil'
        mutations << 'self.foo(::Object.new)'
      end

      it_should_behave_like 'a mutator'
    end

    context 'to some object with keyword in method name' do
      Unparser::Constants::KEYWORDS.each do |keyword|
        context "with keyword #{keyword}" do
          let(:source) { "foo.#{keyword}(nil)" }

          let(:mutations) do
            mutations = []
            mutations << "foo.#{keyword}"
            mutations << 'foo'
            mutations << 'nil'
            mutations << "foo.#{keyword}(::Object.new)"
          end

          it_should_behave_like 'a mutator'
        end
      end
    end

    context 'two arguments' do
      let(:source) { 'foo(nil, nil)' }

      let(:mutations) do
        mutations = []
        mutations << 'foo()'
        mutations << 'foo(nil)'
        mutations << 'foo(::Object.new, nil)'
        mutations << 'foo(nil, ::Object.new)'
      end

      it_should_behave_like 'a mutator'
    end

    context 'binary operator methods' do
      Mutant::BINARY_METHOD_OPERATORS.each do |operator|
        let(:source) { "true #{operator} false" }

        let(:mutations) do
          mutations = []
          mutations << "((false) #{operator} (false))"
          mutations << "((nil) #{operator} (false))"
          mutations << "((true) #{operator} (true))"
          mutations << "((true) #{operator} (nil))"
          mutations << 'true'
          mutations << 'false'
        end

        it_should_behave_like 'a mutator'
      end
    end
  end
end
