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
