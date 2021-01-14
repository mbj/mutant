# frozen_string_literal: true

Mutant::Meta::Example.add :lvar do
  declare_lvar :a

  source 'a'

  mutation 'nil'
end
