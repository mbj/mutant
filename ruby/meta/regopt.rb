# frozen_string_literal: true

Mutant::Meta::Example.add :regopt do
  source '/foo/ixom'

  singleton_mutations
  mutation '//ixom'
  mutation '/nomatch\\A/ixom'
  mutation '/foo/xom'
end
