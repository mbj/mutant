# frozen_string_literal: true

Mutant::Meta::Example.add :index do
  source 'self.foo[]'

  singleton_mutations
  mutation 'self.foo'
  mutation 'self.foo.at()'
  mutation 'self.foo.fetch()'
  mutation 'self.foo.key?()'
  mutation 'self[]'
  mutation 'foo[]'
end

Mutant::Meta::Example.add :index do
  source 'foo[1]'

  singleton_mutations
  mutation '1'
  mutation 'foo'
  mutation 'foo[]'
  mutation 'foo.at(1)'
  mutation 'foo.fetch(1)'
  mutation 'foo.key?(1)'
  mutation 'self[1]'
  mutation 'foo[0]'
  mutation 'foo[2]'
  mutation 'foo[-1]'
  mutation 'foo[nil]'
  mutation 'foo[self]'
end

Mutant::Meta::Example.add :index do
  source 'foo[n..-2]'

  singleton_mutations
  mutation 'n..-2'
  mutation 'foo'
  mutation 'foo[]'
  mutation 'foo.at(n..-2)'
  mutation 'foo.fetch(n..-2)'
  mutation 'foo.key?(n..-2)'
  mutation 'self[n..-2]'
  mutation 'foo[nil]'
  mutation 'foo[self]'
  mutation 'foo[n..nil]'
  mutation 'foo[n..self]'
  mutation 'foo[n..-1]'
  mutation 'foo[n..2]'
  mutation 'foo[n..0]'
  mutation 'foo[n..1]'
  mutation 'foo[n..-3]'
  mutation 'foo[n...-2]'
  mutation 'foo[nil..-2]'
  mutation 'foo[self..-2]'
end

Mutant::Meta::Example.add :index do
  source 'foo[n...-1]'

  singleton_mutations
  mutation 'n...-1'
  mutation 'foo'
  mutation 'foo[]'
  mutation 'foo.at(n...-1)'
  mutation 'foo.fetch(n...-1)'
  mutation 'foo.key?(n...-1)'
  mutation 'self[n...-1]'
  mutation 'foo[nil]'
  mutation 'foo[self]'
  mutation 'foo[n...nil]'
  mutation 'foo[n...self]'
  mutation 'foo[n..-1]'
  mutation 'foo[n...0]'
  mutation 'foo[n...1]'
  mutation 'foo[n...-2]'
  mutation 'foo[nil...-1]'
  mutation 'foo[self...-1]'
end

Mutant::Meta::Example.add :index do
  source 'foo[n..-1]'

  singleton_mutations
  mutation 'n..-1'
  mutation 'foo'
  mutation 'foo[]'
  mutation 'foo.at(n..-1)'
  mutation 'foo.fetch(n..-1)'
  mutation 'foo.key?(n..-1)'
  mutation 'self[n..-1]'
  mutation 'foo[nil]'
  mutation 'foo[self]'
  mutation 'foo[n..nil]'
  mutation 'foo[n..self]'
  mutation 'foo[n..0]'
  mutation 'foo[n..1]'
  mutation 'foo[n..-2]'
  mutation 'foo[n...-1]'
  mutation 'foo[nil..-1]'
  mutation 'foo[self..-1]'
  mutation 'foo.drop(n)'
end

Mutant::Meta::Example.add :index do
  source 'self[foo]'

  singleton_mutations
  mutation 'self[self]'
  mutation 'self[nil]'
  mutation 'self[]'
  mutation 'self.at(foo)'
  mutation 'self.fetch(foo)'
  mutation 'self.key?(foo)'
  mutation 'foo'
end

Mutant::Meta::Example.add :index do
  source 'foo[*bar]'

  singleton_mutations
  mutation 'foo'
  mutation 'foo[]'
  mutation 'foo.at(*bar)'
  mutation 'foo.fetch(*bar)'
  mutation 'foo.key?(*bar)'
  mutation 'foo[nil]'
  mutation 'foo[self]'
  mutation 'foo[bar]'
  mutation 'foo[*self]'
  mutation 'foo[*nil]'
  mutation 'self[*bar]'
end
