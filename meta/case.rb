Mutant::Meta::Example.add :case do
  source <<-RUBY
    case
    when true
    else
    end
  RUBY

  singleton_mutations

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

Mutant::Meta::Example.add :case do
  source <<-RUBY
    case condition
    when A
    when B, C
      C
    else
      D
    end
  RUBY

  singleton_mutations

  mutation <<-RUBY
    case nil
    when A
    when B, C
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case self
    when A
    when B, C
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
      raise
    when B, C
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when nil
    when B, C
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when self
    when B, C
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when B, C
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    when B, C
      nil
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    when B, C
      self
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    when C
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    when nil, C
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    when self, C
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    when B
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    when B, nil
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    when B, self
      C
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    else
      D
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    when B, C
      C
    else
      nil
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    when B, C
      C
    else
      self
    end
  RUBY

  mutation <<-RUBY
    case condition
    when A
    when B, C
      C
    end
  RUBY
end
