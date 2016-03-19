Mutant::Meta::Example.add :const do
  source 'A::B::C'

  singleton_mutations
  mutation 'B::C'
  mutation 'C'
end
