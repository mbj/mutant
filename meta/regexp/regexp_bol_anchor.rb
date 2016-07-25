Mutant::Meta::Example.add :regexp_bol_anchor do
  source '/^/'

  singleton_mutations

  # match all inputs
  mutation '//'

  # match no input
  mutation '/nomatch\A/'

  mutation '/\\A/'
end
