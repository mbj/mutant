# frozen_string_literal: true

Mutant::Meta::Example.add :regexp_eol_anchor do
  source '/$/'

  singleton_mutations
  regexp_mutations

  mutation '/\z/'
end
