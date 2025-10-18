# frozen_string_literal: true

Mutant::Meta::Example.add :numblock do
  source 'foo(false) { _1.to_s }'

  singleton_mutations
  mutation 'foo(true) { _1.to_s }'
  mutation 'foo { _1.to_s }'
end
