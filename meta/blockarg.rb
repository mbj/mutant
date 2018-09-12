# frozen_string_literal: true

Mutant::Meta::Example.add :blockarg do
  source 'foo { |&bar| }'

  singleton_mutations
  mutation 'foo { |&bar| raise }'
  mutation 'foo {}'
  mutation 'foo'
end
