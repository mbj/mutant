# frozen_string_literal: true

Mutant::Meta::Example.add :gvasgn do
  source '$a = true'

  mutation '$a = false'
end
