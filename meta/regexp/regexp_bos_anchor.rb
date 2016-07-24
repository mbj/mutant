Mutant::Meta::Example.add :regexp_bos_anchor do
  source '/\A/'

  singleton_mutations

  # match all inputs
  mutation '//'

  # match no input
  mutation '/nomatch\A/'
end

Mutant::Meta::Example.add :regexp_bos_anchor do
  source '/^#{a}/'

  singleton_mutations

  mutation '/^#{nil}/'
  mutation '/^#{self}/'

  # match all inputs
  mutation '//'

  # match no input
  mutation '/nomatch\A/'
end
