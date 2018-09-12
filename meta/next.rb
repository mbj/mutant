# frozen_string_literal: true

Mutant::Meta::Example.add :next do
  source 'next true'

  singleton_mutations
  mutation 'next false'
  mutation 'next nil'
  mutation 'next'
  mutation 'break true'
end
