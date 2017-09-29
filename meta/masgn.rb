Mutant::Meta::Example.add :masgn do
  source 'a, b = c, d'

  singleton_mutations
  mutation 'a, = c, d'
  mutation 'b, = c, d'
  mutation 'a, b__mutant__ = c, d'
  mutation 'a__mutant__, b = c, d'
end

Mutant::Meta::Example.add :masgn do
  source 'a, b, *c = foo'

  singleton_mutations
  mutation 'a__mutant__, b, *c = foo'
  mutation 'b, *c = foo'
  mutation 'a, b__mutant__, *c = foo'
  mutation 'a, *c = foo'
  mutation 'a, b, c = foo'
  mutation 'a, b = foo'
end
