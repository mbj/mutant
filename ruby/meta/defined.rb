# frozen_string_literal: true

Mutant::Meta::Example.add :defined? do
  source 'defined?(foo)'

  mutation 'nil'
end

Mutant::Meta::Example.add :defined? do
  source 'defined?(@foo)'

  mutation 'instance_variable_defined?(:@foo)'
  mutation 'nil'
end
