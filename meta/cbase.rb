Mutant::Meta::Example.add :cbase do
  source '::A'

  singleton_mutations
  mutation 'A'
end
