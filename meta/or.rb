Mutant::Meta::Example.add :or do
  source 'true or false'

  singleton_mutations
  mutation 'true'
  mutation 'false'
  mutation 'nil or false'
  mutation 'false or false'
  mutation 'true or nil'
  mutation 'true or true'
  mutation 'true and false'
  mutation '!true or false'
end

Mutant::Meta::Example.add :or do
  source 'foo || bar'

  singleton_mutations
  mutation 'foo'
  mutation 'bar'
  mutation 'foo && bar'
  mutation '(!foo) || bar'
  mutation 'nil || bar'
  mutation 'self || bar'
  mutation 'foo || nil'
  mutation 'foo || self'
end

Mutant::Meta::Example.add :or do
  source 'nil || nil'

  singleton_mutations
  mutation 'nil && nil'
  mutation '!nil || nil'
end

Mutant::Meta::Example.add :or do
  source 'foo(bar) || nil'

  singleton_mutations
  mutation 'foo(bar)'
  mutation 'foo(bar) && nil'
  mutation '(!foo(bar)) || nil'
  mutation 'nil || nil'
  mutation 'self || nil'
  mutation 'bar || nil'
  mutation 'foo || nil'
  mutation 'foo(nil) || nil'
  mutation 'foo(self) || nil'
end

Mutant::Meta::Example.add :or do
  source 'foo[bar] || baz'

  singleton_mutations
  mutation 'baz'
  mutation 'foo[bar]'
  mutation 'nil || baz'
  mutation 'foo || baz'
  mutation 'bar || baz'
  mutation 'self || baz'
  mutation 'foo[] || baz'
  mutation 'foo[nil] || baz'
  mutation 'foo[bar] || nil'
  mutation 'foo[bar] && baz'
  mutation 'foo[self] || baz'
  mutation 'foo[bar] || self'
  mutation 'self[bar] || baz'
  mutation '!foo[bar] || baz'
  mutation 'foo.at(bar) || baz'
  mutation 'foo.key?(bar) || baz'
  mutation 'foo.fetch(bar) || baz'
end

Mutant::Meta::Example.add :or do
  source 'foo[bar, nil] || baz'

  singleton_mutations
  mutation 'baz'
  mutation 'foo[bar, nil]'
  mutation 'foo[bar, nil] && baz'
  mutation '!foo[bar, nil] || baz'
  mutation 'nil || baz'
  mutation 'foo || baz'
  mutation 'self || baz'
  mutation 'foo[] || baz'
  mutation 'foo[nil] || baz'
  mutation 'foo[bar] || baz'
  mutation 'foo[bar, nil] || nil'
  mutation 'foo[nil, nil] || baz'
  mutation 'foo[bar, nil] || self'
  mutation 'foo[self, nil] || baz'
  mutation 'self[bar, nil] || baz'
  mutation 'foo.at(bar, nil) || baz'
  mutation 'foo.key?(bar, nil) || baz'
  mutation 'foo.fetch(bar, nil) || baz'
end

Mutant::Meta::Example.add :or do
  source 'foo&.[](:bar) || baz'

  singleton_mutations
  mutation 'foo&.[](:bar)'
  mutation 'baz'
  mutation 'foo&.[](:bar) && baz'
  mutation '(!foo&.[](:bar)) || baz'
  mutation 'nil || baz'
  mutation 'self || baz'
  mutation 'foo || baz'
  mutation 'foo&.at(:bar) || baz'
  mutation 'foo&.fetch(:bar) || baz'
  mutation 'foo&.key?(:bar) || baz'
  mutation ':bar || baz'
  mutation 'self&.[](:bar) || baz'
  mutation 'foo&.[] || baz'
  mutation 'foo&.[](nil) || baz'
  mutation 'foo&.[](self) || baz'
  mutation 'foo&.[](:bar__mutant__) || baz'
  mutation 'foo[:bar] || baz'
  mutation 'foo&.[](:bar) || nil'
  mutation 'foo&.[](:bar) || self'
end
