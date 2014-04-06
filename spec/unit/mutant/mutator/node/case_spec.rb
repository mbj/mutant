# encoding: utf-8

require 'spec_helper'

describe Mutant::Mutator::Node::Case do
  let(:random_string) { 'random' }

  before do
    Mutant::Random.stub(hex_string: random_string)
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
        case :srandom
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
          :srandom
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
          :srandom
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
        when :srandom
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
        when :srandom, :baz
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
        when :bar, :srandom
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
        case :srandom
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
          :srandom
        else
          :else
        end
      RUBY
      mutations << <<-RUBY
        case :condition
        when :foo
          :foo
        else
          :srandom
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
        when :srandom
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
