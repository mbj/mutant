# frozen_string_literal: true

Mutant::Meta::Example.add :lvasgn do
  source 'a = true'

  mutation 'a = false'
end

Mutant::Meta::Example.add :array, :lvasgn do
  source 'a = *b'

  mutation 'a = nil'
  mutation 'a = []'
  mutation 'a = [nil]'
  mutation 'a = [*nil]'
  mutation 'a = [b]'
end
