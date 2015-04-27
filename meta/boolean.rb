Mutant::Meta::Example.add do
  source 'true'

  mutation 'nil'
  mutation 'false'
end

Mutant::Meta::Example.add do
  source 'false'

  mutation 'nil'
  mutation 'true'
end
