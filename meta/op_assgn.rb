# encoding: utf-8

Mutant::Meta::Example.add do
  source '@a.b += 1'

  mutation '@a.b += -1'
  mutation '@a.b += 2'
  mutation '@a.b += 0'
  mutation '@a.b += nil'
  mutation 'nil.b += 1'
  mutation 'nil'
  # TODO: fix invalid AST
  #   This should not get emitted as invalid AST with valid unparsed source
  mutation s(:op_asgn, s(:ivar, :@a), :+, s(:int, 1))
end
