# frozen_string_literal: true

Mutant::Meta::Example.add :op_asgn, :send do
  source '@a.b += 1'

  singleton_mutations

  mutation '@a += 1'
  mutation '@a.b += -1'
  mutation '@a.b += 0'
  mutation '@a.b += 2'
  mutation '@a.b += nil'
  mutation '@a.b += self'
  mutation 'a.b += 1'
  mutation 'self.b += 1'
end

Mutant::Meta::Example.add :op_asgn, :send do
  source 'a.b += 1'

  singleton_mutations

  mutation 'a.b += -1'
  mutation 'a.b += 0'
  mutation 'a.b += 2'
  mutation 'a.b += nil'
  mutation 'a.b += self'
  mutation 'self.b += 1'
end

Mutant::Meta::Example.add :op_asgn, :send do
  source 'b += 1'

  singleton_mutations

  mutation 'b__mutant__ += 1'
  mutation 'b += -1'
  mutation 'b += 0'
  mutation 'b += 2'
  mutation 'b += nil'
  mutation 'b += self'
end
