Mutant::Meta::Example.add :lvasgn do
  source 'a = true'

  singleton_mutations
  mutation 'a__mutant__ = true'
  mutation 'a = false'
  mutation 'a = nil'
end
