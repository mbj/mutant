# frozen_string_literal: true

Mutant::Meta::Example.add :cvar do
  source '@@a'

  singleton_mutations
end
