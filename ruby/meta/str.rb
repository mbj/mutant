# frozen_string_literal: true

Mutant::Meta::Example.add :str do
  source '"foo"'

  singleton_mutations

  mutation '""'
end

Mutant::Meta::Example.add :str do
  source '""'

  singleton_mutations
end
