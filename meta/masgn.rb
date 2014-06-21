# encoding: utf-8

Mutant::Meta::Example.add do
  source 'a, b = c, d'

  singleton_mutations
end
