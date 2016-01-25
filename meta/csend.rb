Mutant::Meta::Example.add do
  source 'a&.b'

  singleton_mutations
  mutation 'a.b'
  mutation 'self&.b'
  mutation 'a'
end
