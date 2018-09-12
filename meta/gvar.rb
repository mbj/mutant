# frozen_string_literal: true

Mutant::Meta::Example.add :gvar do
  source '$a'

  singleton_mutations
end
