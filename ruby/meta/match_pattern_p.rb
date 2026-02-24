# frozen_string_literal: true

Mutant::Meta::Example.add :match_pattern_p, :match_alt do
  source 'x in A | B'

  mutation 'false'
  mutation 'nil in A | B'
  mutation 'x in A'
  mutation 'x in A | nil'
  mutation 'x in B'
  mutation 'x in nil | B'
end
