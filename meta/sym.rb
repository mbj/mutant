Mutant::Meta::Example.add :sym do
  source ':foo'

  singleton_mutations
  mutation ':foo__mutant__'
end
