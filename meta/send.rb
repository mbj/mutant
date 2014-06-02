# encoding: utf-8

Mutant::Meta::Example.add do
  source 'reverse_each'

  mutation 'nil'
  mutation 'each'
end

Mutant::Meta::Example.add do
  source 'reverse_map'

  mutation 'nil'
  mutation 'map'
  mutation 'each'
end

Mutant::Meta::Example.add do
  source 'map'

  mutation 'nil'
  mutation 'each'
end

Mutant::Meta::Example.add do
  source 'foo == bar'

  mutation 'foo'
  mutation 'bar'
  mutation 'nil == bar'
  mutation 'foo == nil'
  mutation 'nil'
  mutation 'foo.eql?(bar)'
  mutation 'foo.equal?(bar)'
end

Mutant::Meta::Example.add do
  source 'foo.gsub(a, b)'

  mutation 'foo'
  mutation 'foo.gsub(a)'
  mutation 'foo.gsub(b)'
  mutation 'foo.gsub'
  mutation 'foo.sub(a, b)'
  mutation 'foo.gsub(a, nil)'
  mutation 'foo.gsub(nil, b)'
  mutation 'nil.gsub(a, b)'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'foo.send(bar)'

  mutation 'foo.send'
  mutation 'foo.public_send(bar)'
  mutation 'bar'
  mutation 'foo'
  mutation 'foo.send(nil)'
  mutation 'nil.send(bar)'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'self.foo ||= expression'

  mutation 'self.foo ||= nil'
  mutation 'nil.foo ||= expression'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'self.bar=baz'

  mutation 'nil'
  mutation 'self.bar=nil'
  mutation 'self'
  mutation 'self.bar'
  mutation 'baz'
  # This one could probably be removed
  mutation 'nil.bar=baz'
end

Mutant::Meta::Example.add do
  source 'foo.bar=baz'

  mutation 'foo'
  mutation 'nil'
  mutation 'foo.bar=nil'
  mutation 'foo.bar'
  mutation 'baz'
  # This one could probably be removed
  mutation 'nil.bar=baz'
end

Mutant::Meta::Example.add do
  source 'foo[bar]=baz'

  mutation 'foo'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'foo(*bar)'

  mutation 'foo'
  mutation 'foo(nil)'
  mutation 'foo(bar)'
  mutation 'foo(*nil)'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'foo(&bar)'

  mutation 'foo'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'foo[*bar]'

  mutation 'foo'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'foo'

  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'self.foo'

  mutation 'foo'
  mutation 'self'
  mutation 'nil.foo'
  mutation 'nil'
end

Unparser::Constants::KEYWORDS.each do |keyword|
  Mutant::Meta::Example.add do
    source "self.#{keyword}"

    mutation "nil.#{keyword}"
    mutation 'nil'
    mutation 'self'
  end
end

Mutant::Meta::Example.add do
  source 'foo.bar'

  mutation 'foo'
  mutation 'nil.bar'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'self.class.foo'

  mutation 'self.class'
  mutation 'self.foo'
  mutation 'nil.class.foo'
  mutation 'nil.foo'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'foo(nil)'

  mutation 'foo'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'self.foo(nil)'

  mutation 'self'
  mutation 'self.foo'
  mutation 'foo(nil)'
  mutation 'nil'
  mutation 'nil.foo(nil)'
end

Unparser::Constants::KEYWORDS.each do |keyword|
  Mutant::Meta::Example.add do
    source "foo.#{keyword}(nil)"

    mutation "foo.#{keyword}"
    mutation 'foo'
    mutation "nil.#{keyword}(nil)"
    mutation 'nil'
  end
end

Mutant::Meta::Example.add do
  source 'foo(nil, nil)'

  mutation 'foo()'
  mutation 'foo(nil)'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source '(left - right) / foo'

  mutation 'foo'
  mutation '(left - right)'
  mutation 'left / foo'
  mutation 'right / foo'
  mutation '(left - right) / nil'
  mutation '(left - nil) / foo'
  mutation '(nil - right) / foo'
  mutation 'nil / foo'
  mutation 'nil'
end

(Mutant::BINARY_METHOD_OPERATORS - [:==, :eql?]).each do |operator|
  Mutant::Meta::Example.add do
    source "true #{operator} false"

    mutation "false #{operator} false"
    mutation "nil   #{operator} false"
    mutation "true  #{operator} true"
    mutation "true  #{operator} nil"
    mutation 'true'
    mutation 'false'
    mutation 'nil'
  end

  Mutant::Meta::Example.add do
    source "left #{operator} right"
    mutation 'left'
    mutation 'right'
    mutation "left #{operator} nil"
    mutation "nil #{operator} right"
    mutation 'nil'
  end
end
