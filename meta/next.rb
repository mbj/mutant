# encoding: utf-8

Mutant::Meta::Example.add do
  source 'next true'

  singleton_mutations
  mutation 'next false'
  mutation 'next nil'
  mutation 'next'
  mutation 'break true'
end
