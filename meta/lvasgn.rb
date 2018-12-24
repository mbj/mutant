# frozen_string_literal: true

Mutant::Meta::Example.add :lvasgn do
  source 'a = true'

  singleton_mutations
  mutation 'a__mutant__ = true'
  mutation 'a = false'
  mutation 'a = nil'
end

Mutant::Meta::Example.add :array, :lvasgn do
  source 'a = *b'

  singleton_mutations
  mutation 'a__mutant__ = *b'
  mutation 'a = nil'
  mutation 'a = self'
  mutation 'a = []'
  mutation 'a = [nil]'
  mutation 'a = [self]'
  mutation 'a = [*self]'
  mutation 'a = [*nil]'
  mutation 'a = [b]'
end
