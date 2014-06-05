# encoding: utf-8

Mutant::Meta::Example.add do
  source 'break true'

  singleton_mutations
  mutation 'break false'
  mutation 'break nil'
  mutation 'break'
  mutation 'next true'
end
