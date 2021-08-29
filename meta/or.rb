# frozen_string_literal: true

Mutant::Meta::Example.add :or do
  source 'true or false'

  singleton_mutations
  mutation 'true'
  mutation 'false'
  mutation 'false or false'
  mutation 'true or true'
  mutation 'true and false'
end

Mutant::Meta::Example.add :or do
  source 'a = true or false'

  singleton_mutations
  mutation 'false'
  mutation 'a = true'
  mutation 'a = false or false'
  mutation 'a = true or true'
  mutation 'a = true and false'
  mutation 'nil or false'
  mutation 'a__mutant__ = true or false'
end
