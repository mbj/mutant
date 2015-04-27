Mutant::Meta::Example.add do
  source 'yield true'

  singleton_mutations
  mutation 'yield false'
  mutation 'yield nil'
  mutation 'yield'
end
