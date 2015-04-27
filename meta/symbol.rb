Mutant::Meta::Example.add do
  source ':foo'

  singleton_mutations
  mutation ':foo__mutant__'
end
