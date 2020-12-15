# frozen_string_literal: true

Mutant::Meta::Example.add :regexp_bos_anchor do
  source '/\A/'

  singleton_mutations
  regexp_mutations
end

Mutant::Meta::Example.add :regexp_bos_anchor do
  source '/^#{a}/'

  singleton_mutations
  regexp_mutations

  mutation '/^#{nil}/'
  mutation '/^#{self}/'
end
