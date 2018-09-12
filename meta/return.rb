# frozen_string_literal: true

Mutant::Meta::Example.add :return do
  source 'return'

  singleton_mutations
end

Mutant::Meta::Example.add :return do
  source 'return foo'

  singleton_mutations
  mutation 'foo'
  mutation 'return nil'
  mutation 'return self'
end
