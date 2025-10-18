# frozen_string_literal: true

Mutant::Meta::Example.add :super do
  source 'super'

  singleton_mutations
end

Mutant::Meta::Example.add :super do
  source 'super()'

  singleton_mutations
end

Mutant::Meta::Example.add :super do
  source 'super(foo, bar)'

  singleton_mutations
  mutation 'super(foo)'
  mutation 'super(bar)'
  mutation 'super(foo, nil)'
  mutation 'super(nil, bar)'
end
