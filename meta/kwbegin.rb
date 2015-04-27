Mutant::Meta::Example.add do
  source 'begin; true; end'

  singleton_mutations
  mutation 'begin; false; end'
  mutation 'begin; nil; end'
end
