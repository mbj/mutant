Mutant::Meta::Example.add :or do
  source 'true or false'

  singleton_mutations
  mutation 'true'
  mutation 'false'
  mutation 'nil or false'
  mutation 'false or false'
  mutation 'true or nil'
  mutation 'true or true'
  mutation 'true and false'
  mutation '!true or false'
end
