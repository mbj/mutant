Mutant::Meta::Example.add :dstr do
  source '"foo#{bar}baz"'

  singleton_mutations
  mutation '"#{nil}#{bar}baz"'
  mutation '"#{self}#{bar}baz"'
  mutation '"foo#{bar}#{nil}"'
  mutation '"foo#{bar}#{self}"'
  mutation '"foo#{nil}baz"'
  mutation '"foo#{self}baz"'
end
