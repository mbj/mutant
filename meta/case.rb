# encoding: utf-8

Mutant::Meta::Example.add do
  source <<-RUBY
    case
    when true
    else
    end
  RUBY

  mutation 'nil'

  mutation <<-RUBY
    case
    when true
      raise
    else
    end
  RUBY
  mutation <<-RUBY
    case
    when false
    else
    end
  RUBY
  mutation <<-RUBY
    case
    when nil
    else
    end
  RUBY
end

Mutant::Meta::Example.add do
  source <<-RUBY
    case :condition
    when :foo
    when :bar, :baz
      :barbaz
    else
      :else
    end
  RUBY

  # Presence of branches
  mutation <<-RUBY
    case :condition
    when :bar, :baz
      :barbaz
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    when :bar, :baz
      :barbaz
    end
  RUBY

  # Mutations of condition
  mutation <<-RUBY
    case nil
    when :foo
    when :bar, :baz
      :barbaz
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition__mutant__
    when :foo
    when :bar, :baz
      :barbaz
    else
      :else
    end
  RUBY

  # Mutations of branch bodies
  mutation <<-RUBY
    case :condition
    when :foo
      raise
    when :bar, :baz
      :barbaz
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    when :bar, :baz
      :barbaz__mutant__
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    when :bar, :baz
      nil
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    when :bar, :baz
      :barbaz
    else
      :else__mutant__
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    when :bar, :baz
      :barbaz
    else
      nil
    end
  RUBY

  # Mutations of when conditions
  mutation <<-RUBY
    case :condition
    when :foo__mutant__
    when :bar, :baz
      :barbaz
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when nil
    when :bar, :baz
      :barbaz
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    when :bar__mutant__, :baz
      :barbaz
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    when nil, :baz
      :barbaz
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    when :bar, nil
      :barbaz
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    when :bar, :baz__mutant__
      :barbaz
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    when :baz
      :barbaz
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
    when :bar
      :barbaz
    else
      :else
    end
  RUBY

  mutation 'nil'
end

Mutant::Meta::Example.add do
  source <<-RUBY
    case :condition
    when :foo
      :foo
    else
      :else
    end
  RUBY

  # Presence of branches
  mutation <<-RUBY
    case :condition
    when :foo
      :foo
    end
  RUBY

  # Mutations of condition
  mutation <<-RUBY
    case nil
    when :foo
      :foo
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition__mutant__
    when :foo
      :foo
    else
      :else
    end
  RUBY

  # Mutations of branch bodies
  mutation <<-RUBY
    case :condition
    when :foo
      nil
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
      :foo__mutant__
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
      :foo
    else
      :else__mutant__
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when :foo
      :foo
    else
      nil
    end
  RUBY

  # Mutations of when conditions
  mutation <<-RUBY
    case :condition
    when :foo__mutant__
      :foo
    else
      :else
    end
  RUBY
  mutation <<-RUBY
    case :condition
    when nil
      :foo
    else
      :else
    end
  RUBY

  mutation 'nil'
end
