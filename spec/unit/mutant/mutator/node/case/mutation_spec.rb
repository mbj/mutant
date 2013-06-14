require 'spec_helper'

describe Mutant::Mutator::Node::Case do
  let(:random_string) { 'random' }

  let(:source) { ':foo' }

  let(:mutations) do
    %w(nil) << ":s#{random_string}"
  end

  before do
    Mutant::Random.stub(:hex_string => random_string)
  end

  let(:source) do
    <<-RUBY
      case :condition
      when :foo
        :foo
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
        :foo
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :foo
      when :bar, :baz
        :barbaz
      end
    RUBY

    # Mutations of condition
    mutations << <<-RUBY
      case nil
      when :foo
        :foo
      when :bar, :baz
        :barbaz
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :srandom
      when :foo
        :foo
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
        nil
      when :bar, :baz
        :barbaz
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :srandom
      when :bar, :baz
        :barbaz
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :foo
      when :bar, :baz
        :srandom
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :foo
      when :bar, :baz
        nil
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :foo
      when :bar, :baz
        :barbaz
      else
        :srandom
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :foo
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
        :foo
      when :bar, :baz
        :barbaz
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when nil
        :foo
      when :bar, :baz
        :barbaz
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :foo
      when :srandom, :baz
        :barbaz
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :foo
      when nil, :baz
        :barbaz
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :foo
      when :bar, nil
        :barbaz
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :foo
      when :bar, :srandom
        :barbaz
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :foo
      when :baz
        :barbaz
      else
        :else
      end
    RUBY
    mutations << <<-RUBY
      case :condition
      when :foo
        :foo
      when :bar
        :barbaz
      else
        :else
      end
    RUBY
  end

  it_should_behave_like 'a mutator'
end
