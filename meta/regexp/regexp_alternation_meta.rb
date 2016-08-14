Mutant::Meta::Example.add :regexp_alternation_meta do
  source '/\A(foo|bar|baz)\z/'

  singleton_mutations
  regexp_mutations
end
