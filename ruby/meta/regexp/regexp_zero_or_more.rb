# frozen_string_literal: true

Mutant::Meta::Example.add :regexp_zero_or_more do
  source '/\d+/'

  singleton_mutations
  regexp_mutations

  mutation '/\D+/'
  mutation '/\d/'
end

Mutant::Meta::Example.add :regexp_greedy_zero_or_more do
  source '/\d*/'

  singleton_mutations
  regexp_mutations

  mutation '/\d/'
  mutation '/\d+/'
  mutation '/\D*/'
end

Mutant::Meta::Example.add :regexp_reluctant_zero_or_more do
  source '/\d*?/'

  singleton_mutations
  regexp_mutations

  mutation '/\d/'
  mutation '/\d+?/'
  mutation '/\D*?/'
end

Mutant::Meta::Example.add :regexp_possessive_zero_or_more do
  source '/\d*+/'

  singleton_mutations
  regexp_mutations

  mutation '/\d/'
  mutation '/\d++/'
  mutation '/\D*+/'
end
