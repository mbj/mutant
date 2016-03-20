Mutant::Meta::Example.add :nthref do
  source '$1'

  mutation '$2'
end

Mutant::Meta::Example.add :nthref do
  source '$2'

  mutation '$3'
  mutation '$1'
end
