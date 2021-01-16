# frozen_string_literal: true

Mutant::Meta::Example.add :dsym do
  source ':"foo#{bar}baz"'

  singleton_mutations

  mutation ':"foo#{nil}baz"'
end
