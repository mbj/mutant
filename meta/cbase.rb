# encoding: utf-8

Mutant::Meta::Example.add do
  source '::A'

  singleton_mutations
  mutation 'A'
end
