Mutant::Meta::Example.add :op_asgn do
  source '@a.b += 1'

  singleton_mutations
  mutation 'a.b += 1'
  mutation '@a.b += -1'
  mutation '@a.b += 2'
  mutation '@a.b += 0'
  mutation '@a.b += nil'
  mutation '@a.b += self'
  mutation 'self.b += 1'
  # TODO: fix invalid AST
  #   This should not get emitted as invalid AST with valid unparsed source
  mutation s(:op_asgn, s(:ivar, :@a), :+, s(:int, 1))
end
