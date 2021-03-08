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
end

unless RUBY_VERSION.start_with?('2.5')
  Mutant::Meta::Example.add :erange do
    source '1...'

    singleton_mutations
    mutation '0...'
    mutation '2...'
    mutation 'nil...'
  end

  Mutant::Meta::Example.add :irange do
    source '1..'

    singleton_mutations
    mutation '0..'
    mutation '2..'
    mutation 'nil..'
  end
end

if RUBY_VERSION >= '2.7.'
  Mutant::Meta::Example.add :erange do
    source '...1'

    singleton_mutations
    mutation '...0'
    mutation '..1'
    mutation '...2'
    mutation '...nil'
  end

  Mutant::Meta::Example.add :irange do
    source '..1'

    singleton_mutations
    mutation '..0'
    mutation '...1'
    mutation '..2'
    mutation '..nil'
  end
end
