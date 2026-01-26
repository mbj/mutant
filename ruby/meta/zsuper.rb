# frozen_string_literal: true

Mutant::Meta::Example.add :zsuper do
  source 'super'

  singleton_mutations
  mutation 'super()'
end
