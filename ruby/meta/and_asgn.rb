# frozen_string_literal: true

Mutant::Meta::Example.add :and_asgn do
  source 'a &&= 1'

  mutation 'a &&= nil'
  mutation 'a &&= 0'
  mutation 'a &&= 2'
end
