Mutant::Meta::Example.add do
  source 'A = true'

  mutation 'A__MUTANT__ = true'
  mutation 'A = false'
  mutation 'A = nil'
end
