Mutant::Meta::Example.add :lvasgn do
  source 'a = true'

  singleton_mutations
  mutation 'a__mutant__ = true'
  mutation 'a = false'
  mutation 'a = nil'
end

Mutant::Meta::Example.add :lvasgn do
  source 'a, b = foo'

  singleton_mutations
  mutation 'a__mutant__, b = foo'
  mutation 'a, b__mutant__ = foo'
  mutation 'b, = foo'
  mutation 'a, = foo'
end

Mutant::Meta::Example.add :lvasgn do
  source 'a = nil; a'

  mutation 'a = nil; nil'
  mutation 'a = nil; self'
  mutation 'a = nil'
  # TODO: fix invalid AST
  #   These ASTs are not valid and should NOT be emitted
  #   Mutations of lvarasgn need to be special cased to avoid this.
  # mutation s(:begin, s(:lvasgn, :a__mutant__, s(:nil)), s(:lvar, :a))
  # mutation s(:begin, s(:nil), s(:lvar, :a))
  # mutation s(:begin, s(:self), s(:lvar, :a))
  # mutation s(:lvar, :a)
end
