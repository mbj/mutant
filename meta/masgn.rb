# frozen_string_literal: true

Mutant::Meta::Example.add :masgn do
  source 'a, b = c, d'

  singleton_mutations
end
