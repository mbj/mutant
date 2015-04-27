Mutant::Meta::Example.add do
  source 'A::B::C'

  singleton_mutations
  mutation 'B::C'
  mutation 'C'
end
