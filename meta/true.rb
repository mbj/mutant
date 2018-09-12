# frozen_string_literal: true

Mutant::Meta::Example.add :true do
  source 'true'

  mutation 'nil'
  mutation 'false'
end
