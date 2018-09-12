# frozen_string_literal: true

Mutant::Meta::Example.add :regexp_eos_anchor do
  source '/\z/'

  singleton_mutations
  regexp_mutations
end
