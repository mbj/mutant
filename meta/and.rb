Mutant::Meta::Example.add :and do
  source 'true and false'

  singleton_mutations
  mutation 'true'
  mutation 'false'
  mutation 'true or false'
  mutation 'true and nil'
  mutation 'nil and false'
  mutation 'false and false'
  mutation 'true and true'
  mutation '!true and false'
end

Mutant::Meta::Example.add :and do
  source 'foo[bar] and baz'

  singleton_mutations
  mutation 'baz'
  mutation 'foo[bar]'
  mutation 'bar && baz'
  mutation 'foo && baz'
  mutation 'nil && baz'
  mutation 'self && baz'
  mutation 'foo[] && baz'
  mutation 'foo[nil] && baz'
  mutation 'foo[bar] || baz'
  mutation 'foo[bar] && nil'
  mutation 'foo[bar] && self'
  mutation 'foo[self] && baz'
  mutation 'self[bar] && baz'
  mutation '(!foo[bar]) && baz'
  mutation 'foo.at(bar) && baz'
  mutation 'foo.key?(bar) && baz'
  mutation 'foo.fetch(bar) && baz'
end
