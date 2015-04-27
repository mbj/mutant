Mutant::Meta::Example.add do
  source 'begin; rescue; ensure; true; end'

  singleton_mutations
  mutation 'begin; rescue; ensure; false; end'
  mutation 'begin; rescue; ensure; nil; end'
end
