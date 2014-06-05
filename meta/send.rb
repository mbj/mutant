# encoding: utf-8

Mutant::Meta::Example.add do
  source 'reverse_each'

  singleton_mutations
  mutation 'each'
end

Mutant::Meta::Example.add do
  source 'reverse_map'

  singleton_mutations
  mutation 'map'
  mutation 'each'
end

Mutant::Meta::Example.add do
  source 'map'

  singleton_mutations
  mutation 'each'
end

Mutant::Meta::Example.add do
  source 'foo == bar'

  singleton_mutations
  mutation 'foo'
  mutation 'bar'
  mutation 'nil == bar'
  mutation 'self == bar'
  mutation 'foo == nil'
  mutation 'foo == self'
  mutation 'foo.eql?(bar)'
  mutation 'foo.equal?(bar)'
end

Mutant::Meta::Example.add do
  source 'foo.gsub(a, b)'

  singleton_mutations
  mutation 'foo'
  mutation 'foo.gsub(a)'
  mutation 'foo.gsub(b)'
  mutation 'foo.gsub'
  mutation 'foo.sub(a, b)'
  mutation 'foo.gsub(a, nil)'
  mutation 'foo.gsub(a, self)'
  mutation 'foo.gsub(nil, b)'
  mutation 'foo.gsub(self, b)'
  mutation 'nil.gsub(a, b)'
  mutation 'self.gsub(a, b)'
end

Mutant::Meta::Example.add do
  source 'foo.send(bar)'

  singleton_mutations
  mutation 'foo.send'
  mutation 'foo.public_send(bar)'
  mutation 'bar'
  mutation 'foo'
  mutation 'self.send(bar)'
  mutation 'foo.send(nil)'
  mutation 'foo.send(self)'
  mutation 'nil.send(bar)'
end

Mutant::Meta::Example.add do
  source 'self.bar = baz'

  singleton_mutations
  mutation 'self.bar = nil'
  mutation 'self.bar = self'
  mutation 'self.bar'
  mutation 'baz'
  # This one could probably be removed
  mutation 'nil.bar=baz'
end

Mutant::Meta::Example.add do
  source 'foo.bar = baz'

  singleton_mutations
  mutation 'foo'
  mutation 'foo.bar = nil'
  mutation 'foo.bar = self'
  mutation 'self.bar = baz'
  mutation 'foo.bar'
  mutation 'baz'
  # This one could probably be removed
  mutation 'nil.bar = baz'
end

Mutant::Meta::Example.add do
  source 'foo[bar]=baz'

  singleton_mutations
  mutation 'foo'
end

Mutant::Meta::Example.add do
  source 'foo(*bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'foo(nil)'
  mutation 'foo(bar)'
  mutation 'foo(self)'
  mutation 'foo(*nil)'
  mutation 'foo(*self)'
end

Mutant::Meta::Example.add do
  source 'foo(&bar)'

  singleton_mutations
  mutation 'foo'
end

Mutant::Meta::Example.add do
  source 'foo[*bar]'

  singleton_mutations
  mutation 'foo'
end

Mutant::Meta::Example.add do
  source 'foo'

  singleton_mutations
end

Mutant::Meta::Example.add do
  source 'self.foo'

  singleton_mutations
  mutation 'foo'
  mutation 'nil.foo'
end

Unparser::Constants::KEYWORDS.each do |keyword|
  Mutant::Meta::Example.add do
    source "self.#{keyword}"

    singleton_mutations
    mutation "nil.#{keyword}"
  end
end

Mutant::Meta::Example.add do
  source 'foo.bar'

  singleton_mutations
  mutation 'foo'
  mutation 'nil.bar'
  mutation 'self.bar'
end

Mutant::Meta::Example.add do
  source 'self.class.foo'

  singleton_mutations
  mutation 'self.class'
  mutation 'self.foo'
  mutation 'nil.class.foo'
  mutation 'nil.foo'
end

Mutant::Meta::Example.add do
  source 'foo(nil)'

  singleton_mutations
  mutation 'foo'
end

Mutant::Meta::Example.add do
  source 'self.foo(nil)'

  singleton_mutations
  mutation 'self.foo'
  mutation 'foo(nil)'
  mutation 'nil.foo(nil)'
end

Unparser::Constants::KEYWORDS.each do |keyword|
  Mutant::Meta::Example.add do
    source "foo.#{keyword}(nil)"

    singleton_mutations
    mutation "self.#{keyword}(nil)"
    mutation "foo.#{keyword}"
    mutation 'foo'
    mutation "nil.#{keyword}(nil)"
  end
end

Mutant::Meta::Example.add do
  source 'foo(nil, nil)'

  singleton_mutations
  mutation 'foo()'
  mutation 'foo(nil)'
end

Mutant::Meta::Example.add do
  source '(left - right) / foo'

  singleton_mutations
  mutation 'foo'
  mutation '(left - right)'
  mutation 'left / foo'
  mutation 'right / foo'
  mutation '(left - right) / nil'
  mutation '(left - right) / self'
  mutation '(left - nil) / foo'
  mutation '(left - self) / foo'
  mutation '(nil - right) / foo'
  mutation '(self - right) / foo'
  mutation 'nil / foo'
  mutation 'self / foo'
end

(Mutant::BINARY_METHOD_OPERATORS - [:==, :eql?]).each do |operator|
  Mutant::Meta::Example.add do
    source "true #{operator} false"

    singleton_mutations
    mutation 'true'
    mutation 'false'
    mutation "false #{operator} false"
    mutation "nil   #{operator} false"
    mutation "true  #{operator} true"
    mutation "true  #{operator} nil"
  end
end
