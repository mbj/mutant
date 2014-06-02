# encoding: utf-8

Mutant::Meta::Example.add do
  source '10'

  # generic
  mutation 'nil'

  # edge cases
  mutation '0'
  mutation '1'

  # negative
  mutation '-10'

  # scalar boundary
  mutation '9'
  mutation '11'
end
