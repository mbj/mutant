# frozen_string_literal: true

Mutant::Meta::Example.add :irange do
  source '1..100'

  singleton_mutations
  mutation '1...100'
  mutation '-1..100'
  mutation '0..100'
  mutation '2..100'
  mutation 'nil..100'
  mutation 'self..100'
  mutation '1..nil'
  mutation '1..self'
  mutation '1..0'
  mutation '1..1'
  mutation '1..99'
  mutation '1..101'
  mutation '1..-100'
end

Mutant::Meta::Example.add :erange do
  source '1...100'

  singleton_mutations
  mutation '1..100'
  mutation '-1...100'
  mutation '0...100'
  mutation '2...100'
  mutation 'nil...100'
  mutation 'self...100'
  mutation '1...nil'
  mutation '1...self'
  mutation '1...0'
  mutation '1...1'
  mutation '1...99'
  mutation '1...101'
  mutation '1...-100'
end
