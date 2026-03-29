# frozen_string_literal: true

Mutant::Meta::Example.add :irange do
  source '1..100'

  singleton_mutations
  mutation '1...100'
  mutation '0..100'
  mutation '2..100'
  mutation 'nil..100'
  mutation '1..nil'
  mutation '1..0'
  mutation '1..1'
  mutation '1..99'
  mutation '1..101'

  # overflow boundary probes (int8 zone)
  mutation '167..100'
  mutation '1..167'
end

Mutant::Meta::Example.add :erange do
  source '1...100'

  singleton_mutations
  mutation '1..100'
  mutation '0...100'
  mutation '2...100'
  mutation 'nil...100'
  mutation '1...nil'
  mutation '1...0'
  mutation '1...1'
  mutation '1...99'
  mutation '1...101'

  # overflow boundary probes (int8 zone)
  mutation '167...100'
  mutation '1...167'
end

Mutant::Meta::Example.add :erange do
  source '1...'

  singleton_mutations
  mutation '0...'
  mutation '2...'
  mutation 'nil...'

  # overflow boundary probe (int8 zone)
  mutation '167...'
end

Mutant::Meta::Example.add :irange do
  source '1..'

  singleton_mutations
  mutation '0..'
  mutation '2..'
  mutation 'nil..'

  # overflow boundary probe (int8 zone)
  mutation '167..'
end

Mutant::Meta::Example.add :erange do
  source '...1'

  singleton_mutations
  mutation '...0'
  mutation '..1'
  mutation '...2'
  mutation '...nil'

  # overflow boundary probe (int8 zone)
  mutation '...167'
end

Mutant::Meta::Example.add :irange do
  source '..1'

  singleton_mutations
  mutation '..0'
  mutation '...1'
  mutation '..2'
  mutation '..nil'

  # overflow boundary probe (int8 zone)
  mutation '..167'
end
