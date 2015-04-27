Mutant::Meta::Example.add do
  source 'return'

  singleton_mutations
end

Mutant::Meta::Example.add do
  source 'return foo'

  singleton_mutations
  mutation 'foo'
  mutation 'return nil'
  mutation 'return self'
end
