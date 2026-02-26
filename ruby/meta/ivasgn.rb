# frozen_string_literal: true

Mutant::Meta::Example.add :ivasgn do
  source '@a = true'

  mutation '@a = false'
end

Mutant::Meta::Example.add :ivasgn do
  source '@a &&= 1'

  mutation '@a &&= nil'
  mutation '@a &&= 0'
  mutation '@a &&= 2'
  mutation '@a ||= 1'
end
