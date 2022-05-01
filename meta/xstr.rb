# frozen_string_literal: true

Mutant::Meta::Example.add :xstr do
  source '`a #{true}`'

  singleton_mutations

  mutation '`a #{false}`'
end
