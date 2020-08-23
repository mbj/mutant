# frozen_string_literal: true

Mutant::Meta::Example.add :gvasgn do
  source '$a = true'

  singleton_mutations
  mutation '$a__mutant__ = true'
  mutation '$a = false'
end
