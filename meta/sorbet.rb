# frozen_string_literal: true

Mutant::Meta::Example.add :send do
  source 'T.must(a > b)'
end

Mutant::Meta::Example.add :send do
  source '::T.must(a > b)'
end

Mutant::Meta::Example.add :case do
  source <<~RUBY
    case
    when true
    else
      T.absurd(true)
    end
  RUBY

  singleton_mutations

  mutation <<-RUBY
    case
    when true
      raise
    else T.absurd(true)
    end
  RUBY

  mutation <<-RUBY
    case
    when false
    else T.absurd(true)
    end
  RUBY
end
