# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Case do
  context 'without condition' do
    let(:source) do
      <<-RUBY
        case
        when true
        else
        end
      RUBY
    end

    let(:mutations) do
      mutations = []
      mutations << 'nil'
      mutations << <<-RUBY
        case
        when true
          raise
        else
        end
      RUBY
      mutations << <<-RUBY
        case
        when false
        else
        end
      RUBY
      mutations << <<-RUBY
        case
        when nil
        else
        end
      RUBY
    end

    it_should_behave_like 'a mutator'
  end

  context 'with multiple when branches' do
    let(:source) do
      <<-RUBY
        case :condition
        when :foo
        when :bar, :baz
          :barbaz
        else
          :else
        end
      RUBY
    end

    let(:mutations) do
      mutations = []

      # Presence of branches
      mutations << <<-RUBY
        case :condition
        when :bar, :baz
          :barbaz
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        when :bar, :baz
          :barbaz
        end
      RUBY

      # Mutations of condition
      mutations << <<-RUBY
        case nil
        when :foo
        when :bar, :baz
          :barbaz
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition__mutant__
        when :foo
        when :bar, :baz
          :barbaz
        else
          :else
        end
      RUBY

      # Mutations of branch bodies
      mutations << <<-RUBY
        case :condition
        when :foo
          raise
        when :bar, :baz
          :barbaz
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        when :bar, :baz
          :barbaz__mutant__
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        when :bar, :baz
          nil
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        when :bar, :baz
          :barbaz
        else
          :else__mutant__
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        when :bar, :baz
          :barbaz
        else
          nil
        end
      RUBY

      # Mutations of when conditions
      mutations << <<-RUBY
        case :condition
        when :foo__mutant__
        when :bar, :baz
          :barbaz
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when nil
        when :bar, :baz
          :barbaz
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        when :bar__mutant__, :baz
          :barbaz
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        when nil, :baz
          :barbaz
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        when :bar, nil
          :barbaz
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        when :bar, :baz__mutant__
          :barbaz
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        when :baz
          :barbaz
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
        when :bar
          :barbaz
        else
          :else
        end
      RUBY

      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end

  context 'with one when branch' do
    let(:source) do
      <<-RUBY
        case :condition
        when :foo
          :foo
        else
          :else
        end
      RUBY
    end

    let(:mutations) do
      mutations = []

      # Presence of branches
      mutations << <<-RUBY
        case :condition
        when :foo
          :foo
        end
      RUBY

      # Mutations of condition
      mutations << <<-RUBY
        case nil
        when :foo
          :foo
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition__mutant__
        when :foo
          :foo
        else
          :else
        end
      RUBY

      # Mutations of branch bodies
      mutations << <<-RUBY
        case :condition
        when :foo
          nil
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
          :foo__mutant__
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
          :foo
        else
          :else__mutant__
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
          :foo
        else
          nil
        end
      RUBY

      # Mutations of when conditions
      mutations << <<-RUBY
        case :condition
        when :foo__mutant__
          :foo
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when nil
          :foo
        else
          :else
        end
      RUBY

      mutations << 'nil'
    end

    it_should_behave_like 'a mutator'
  end
end
