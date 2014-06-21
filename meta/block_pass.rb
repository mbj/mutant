# encoding: utf-8

Mutant::Meta::Example.add do
  source 'foo(&bar)'

  singleton_mutations
  mutation 'foo'
end
