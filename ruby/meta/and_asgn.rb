# frozen_string_literal: true

Mutant::Meta::Example.add :and_asgn do
  source 'a &&= 1'

  mutation 'a &&= nil'
  mutation 'a &&= 0'
  mutation 'a &&= 2'
  mutation 'a ||= 1'

  # overflow boundary probe (int8 zone)
  mutation 'a &&= 167'
end
