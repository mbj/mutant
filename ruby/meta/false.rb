# frozen_string_literal: true

Mutant::Meta::Example.add :false do
  source 'false'

  mutation 'true'
end
