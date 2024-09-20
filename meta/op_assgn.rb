# frozen_string_literal: true

Mutant::Meta::Example.add :op_asgn, :send do
  source '@a.b += 1'

  mutation '@a += 1'
  mutation '@a.b += 0'
  mutation '@a.b += 2'
  mutation '@a.b += nil'
  mutation 'a.b += 1'
  mutation 'self.b += 1'
end

Mutant::Meta::Example.add :op_asgn, :send do
  source 'a.b += 1'

  mutation 'a.b += 0'
  mutation 'a.b += 2'
  mutation 'a.b += nil'
  mutation 'self.b += 1'
end

Mutant::Meta::Example.add :op_asgn, :send do
  source 'b += 1'

  mutation 'b += 0'
  mutation 'b += 2'
  mutation 'b += nil'
end
