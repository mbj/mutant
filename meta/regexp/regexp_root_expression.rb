Mutant::Meta::Example.add :regexp_root_expression do
  source '/^/'

  singleton_mutations

  # match all inputs
  mutation '//'

  # match no input
  mutation '/nomatch\A/'

  mutation '/\\A/'
end
