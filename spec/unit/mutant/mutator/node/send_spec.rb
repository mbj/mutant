# encoding: utf-8

require 'spec_helper'

# FIXME: This spec needs to be structured better!
describe Mutant::Mutator, 'send' do

  context 'when using #==' do
    let(:source) { 'foo == bar' }

    let(:mutations) do
      mutations = []
      mutations << 'foo'
      mutations << 'bar'
      mutations << 'nil == bar'
      mutations << 'foo == nil'
      mutations << 'nil'
      mutations << 'foo.eql?(bar)'
      mutations << 'foo.equal?(bar)'
    end

    it_should_behave_like 'a mutator'
  end

  context 'when using #gsub' do
    let(:source) { 'foo.gsub(a, b)' }

    let(:mutations) do
      mutations = []
      mutations << 'foo'
      mutations << 'foo.gsub(a)'
      mutations << 'foo.gsub(b)'
      mutations << 'foo.gsub'
      mutations << 'foo.sub(a, b)'
      mutations << 'foo.gsub(a, nil)'
      mutations << 'foo.gsub(nil, b)'
      mutations << 'nil.gsub(a, b)'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'when using Kernel#send' do
    let(:source) { 'foo.send(bar)' }

    let(:mutations) do
      mutations = []
      mutations << 'foo.send'
      mutations << 'foo.public_send(bar)'
      mutations << 'bar'
      mutations << 'foo'
      mutations << 'foo.send(nil)'
      mutations << 'nil.send(bar)'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'inside op assign' do
    let(:source) { 'self.foo ||= expression' }

    let(:mutations) do
      mutations = []
      mutations << 'self.foo ||= nil'
      mutations << 'nil.foo ||= expression'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'attribute assign' do

    context 'to self' do
      let(:source) { 'self.bar=baz' }

      let(:mutations) do
        mutations = []
        mutations << 'nil'
        mutations << 'self.bar=nil'
        mutations << 'self'
        mutations << 'self.bar'
        mutations << 'baz'
        # This one could probably be removed
        mutations << 'nil.bar=baz'
      end

      it_should_behave_like 'a mutator'
    end

    context 'to other object' do
      let(:source) { 'foo.bar=baz' }

      let(:mutations) do
        mutations = []
        mutations << 'foo'
        mutations << 'nil'
        mutations << 'foo.bar=nil'
        mutations << 'foo.bar'
        mutations << 'baz'
        # This one could probably be removed
        mutations << 'nil.bar=baz'
      end

      it_should_behave_like 'a mutator'
    end
  end

  context 'index assign' do
    let(:source) { 'foo[bar]=baz' }

    let(:mutations) do
      mutations = []
      mutations << 'foo'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with only a splat arg' do
    let(:source) { 'foo(*bar)' }

    let(:mutations) do
      mutations = []
      mutations << 'foo'
      mutations << 'foo(nil)'
      mutations << 'foo(bar)'
      mutations << 'foo(*nil)'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with only a block arg' do
    let(:source) { 'foo(&bar)' }

    let(:mutations) do
      mutations = []
      mutations << 'foo'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'single splat arg splat' do
    let(:source) { 'foo[*bar]' }

    let(:mutations) do
      mutations = []
      mutations << 'foo'
      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with self as' do
    context 'implicit' do
      let(:source) { 'foo' }

      let(:mutations) do
        mutations = []
        mutations << 'nil'
      end

      it_should_behave_like 'a mutator'
    end

    context 'explict receiver' do
      let(:source) { 'self.foo' }

      let(:mutations) do
        mutations = []
        mutations << 'foo'
        mutations << 'self'
        mutations << 'nil.foo'
        mutations << 'nil'
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
        mutations << 'nil.bar'
        mutations << 'nil'
      end

      it_should_behave_like 'a mutator'
    end

    context 'to self.class.foo' do
      let(:source) { 'self.class.foo' }

      let(:mutations) do
        mutations = []
        mutations << 'self.class'
        mutations << 'self.foo'
        mutations << 'nil.class.foo'
        mutations << 'nil.foo'
        mutations << 'nil'
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
        mutations << 'nil.foo(nil)'
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
            mutations << "nil.#{keyword}(nil)"
            mutations << 'nil'
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
        mutations << 'nil'
      end

      it_should_behave_like 'a mutator'
    end

    context 'binary operator methods' do
      context 'nested' do
        let(:source) { '(left - right) / foo' }

        let(:mutations) do
          mutations = []
          mutations << 'foo'
          mutations << '(left - right)'
          mutations << 'left / foo'
          mutations << 'right / foo'
          mutations << '(left - right) / nil'
          mutations << '(left - nil) / foo'
          mutations << '(nil - right) / foo'
          mutations << 'nil / foo'
          mutations << 'nil'
        end

        it_should_behave_like 'a mutator'
      end

      (Mutant::BINARY_METHOD_OPERATORS - [:==, :eql?]).each do |operator|
        context 'on literal scalar arguments' do
          let(:source) { "true #{operator} false" }

          let(:mutations) do
            mutations = []
            mutations << "false #{operator} false"
            mutations << "nil   #{operator} false"
            mutations << "true  #{operator} true"
            mutations << "true  #{operator} nil"
            mutations << 'true'
            mutations << 'false'
            mutations << 'nil'
          end

          it_should_behave_like 'a mutator'
        end

        context 'on non literal scalar arguments' do
          let(:source) { "left #{operator} right" }
          let(:mutations) do
            mutations = []
            mutations << 'left'
            mutations << 'right'
            mutations << "left #{operator} nil"
            mutations << "nil #{operator} right"
            mutations << 'nil'
          end

          it_should_behave_like 'a mutator'
        end
      end
    end
  end
end
