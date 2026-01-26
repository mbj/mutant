# frozen_string_literal: true

Mutant::Meta::Example.add :indexasgn do
  source 'foo[bar] = baz'

  singleton_mutations
  mutation 'self[bar] = baz'
  mutation 'foo'
  mutation 'foo[bar]'
  mutation 'foo.at(bar)'
  mutation 'foo.fetch(bar)'
  mutation 'foo.key?(bar)'
  mutation 'foo[bar] = nil'
  mutation 'foo[nil] = baz'
  mutation 'foo[] = baz'
  mutation 'baz'
end

Mutant::Meta::Example.add :indexasgn, :op_asgn do
  source 'self[foo] += bar'

  mutation 'self[] += bar'
  mutation 'self[nil] += bar'
  mutation 'self[foo] += nil'
  mutation 'self[foo] -= bar'
end
