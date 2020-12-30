# frozen_string_literal: true

Mutant::Meta::Example.add :regexp_eos_ob_eol_anchor do
  source '/\Z/'

  singleton_mutations
  regexp_mutations

  mutation '/\z/'
end
