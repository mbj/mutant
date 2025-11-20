# frozen_string_literal: true

Mutant::Meta::Example.add :self do
  source 'self'

  mutation 'nil'
end
