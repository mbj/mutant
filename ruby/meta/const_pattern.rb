# frozen_string_literal: true

Mutant::Meta::Example.add :const_pattern do
  source <<~'RUBY'
    case nil
    in A(foo, bar)
    end
  RUBY
end
