# frozen_string_literal: true

Mutant::Meta::Example.add :true do
  source 'true'

  mutation 'false'
end
