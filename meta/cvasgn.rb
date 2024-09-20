# frozen_string_literal: true

Mutant::Meta::Example.add :cvasgn do
  source '@@a = true'

  mutation '@@a = false'
end
