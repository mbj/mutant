Mutant::Meta::Example.add :regexp do
  source '/foo/'

  singleton_mutations

  # match all inputs
  mutation '//'

  # match no input
  mutation '/nomatch\A/'
end

Mutant::Meta::Example.add :regexp do
  source '/#{foo.bar}n/'

  singleton_mutations
  mutation '/#{foo}n/'
  mutation '/#{self.bar}n/'
  mutation '/#{nil}n/'
  mutation '/#{self}n/'

  # match all inputs
  mutation '//'

  # match no input
  mutation '/nomatch\A/'
end

Mutant::Meta::Example.add :regexp do
  source 'true if /foo/'

  singleton_mutations
  mutation 'false if /foo/'
  mutation 'nil if /foo/'
  mutation 'true if true'
  mutation 'true if false'
  mutation 'true if nil'
  mutation 'true'

  # match all inputs
  mutation 'true if //'

  # match no input
  mutation 'true if /nomatch\A/'
end
