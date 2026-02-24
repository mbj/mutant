# frozen_string_literal: true

Mutant::Meta::Example.add :complex do
  source '10i'

  singleton_mutations

  mutation '0i'
  mutation '1i'
  mutation '11i'
  mutation '9i'
end
