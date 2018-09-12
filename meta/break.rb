# frozen_string_literal: true

Mutant::Meta::Example.add :break do
  source 'break true'

  singleton_mutations
  mutation 'break false'
  mutation 'break nil'
  mutation 'break'
end
