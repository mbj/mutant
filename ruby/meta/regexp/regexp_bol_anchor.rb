# frozen_string_literal: true

Mutant::Meta::Example.add :regexp_bol_anchor do
  source '/^/'

  singleton_mutations
  regexp_mutations

  mutation '/\\A/'
end
