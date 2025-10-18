# frozen_string_literal: true

Mutant::Meta::Example.add :regexp_capture_group do
  source '/()/'

  singleton_mutations
  regexp_mutations
end

Mutant::Meta::Example.add :regexp_capture_group do
  source '/(foo|bar)/'

  singleton_mutations
  regexp_mutations

  mutation '/(?:foo|bar)/'
  mutation '/(foo)/'
  mutation '/(bar)/'
end

Mutant::Meta::Example.add :regexp_capture_group do
  source '/(\w\d)/'

  singleton_mutations
  regexp_mutations

  mutation '/(?:\w\d)/'
  mutation '/(\W\d)/'
  mutation '/(\w\D)/'
end
