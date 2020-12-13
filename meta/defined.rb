# frozen_string_literal: true

Mutant::Meta::Example.add :defined? do
  source 'defined?(foo)'

  singleton_mutations
  mutation 'defined?(nil)'
  mutation 'true'
end

Mutant::Meta::Example.add :defined? do
  source 'defined?(@foo)'

  singleton_mutations
  mutation 'defined?(nil)'
  mutation 'defined?(foo)'
  mutation 'true'
  mutation 'instance_variable_defined?(:@foo)'
end
