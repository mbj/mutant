Mutant::Meta::Example.add do
  source 'a > b'

  singleton_mutations
  mutation 'a == b'
  mutation 'a >= b'
  mutation 'a.eql?(b)'
  mutation 'a.equal?(b)'
  mutation 'nil > b'
  mutation 'self > b'
  mutation 'a > nil'
  mutation 'a > self'
  mutation 'a'
  mutation 'b'
end

Mutant::Meta::Example.add do
  source 'A.const_get(:B)'

  singleton_mutations
  mutation 'A::B'
  mutation 'A.const_get'
  mutation 'A'
  mutation ':B'
  mutation 'A.const_get(nil)'
  mutation 'A.const_get(self)'
  mutation 'A.const_get(:B__mutant__)'
  mutation 'self.const_get(:B)'
end

Mutant::Meta::Example.add do
  source 'A.const_get(bar)'

  singleton_mutations
  mutation 'A.const_get'
  mutation 'A'
  mutation 'bar'
  mutation 'A.const_get(nil)'
  mutation 'A.const_get(self)'
  mutation 'self.const_get(bar)'
end

Mutant::Meta::Example.add do
  source 'a >= b'

  singleton_mutations
  mutation 'a > b'
  mutation 'a == b'
  mutation 'a.eql?(b)'
  mutation 'a.equal?(b)'
  mutation 'nil >= b'
  mutation 'self >= b'
  mutation 'a >= nil'
  mutation 'a >= self'
  mutation 'a'
  mutation 'b'
end

Mutant::Meta::Example.add do
  source 'a <= b'

  singleton_mutations
  mutation 'a < b'
  mutation 'a == b'
  mutation 'a.eql?(b)'
  mutation 'a.equal?(b)'
  mutation 'nil <= b'
  mutation 'self <= b'
  mutation 'a <= nil'
  mutation 'a <= self'
  mutation 'a'
  mutation 'b'
end

Mutant::Meta::Example.add do
  source 'a < b'

  singleton_mutations
  mutation 'a == b'
  mutation 'a <= b'
  mutation 'a.eql?(b)'
  mutation 'a.equal?(b)'
  mutation 'nil < b'
  mutation 'self < b'
  mutation 'a < nil'
  mutation 'a < self'
  mutation 'a'
  mutation 'b'
end

Mutant::Meta::Example.add do
  source 'reverse_each'

  singleton_mutations
  mutation 'each'
end

Mutant::Meta::Example.add do
  source 'reverse_merge'

  singleton_mutations
  mutation 'merge'
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
  source 'foo.to_s'

  singleton_mutations
  mutation 'foo'
  mutation 'self.to_s'
  mutation 'foo.to_str'
end

Mutant::Meta::Example.add do
  source 'foo.to_a'

  singleton_mutations
  mutation 'foo'
  mutation 'self.to_a'
  mutation 'foo.to_ary'
end

Mutant::Meta::Example.add do
  source 'foo.to_i'

  singleton_mutations
  mutation 'foo'
  mutation 'self.to_i'
  mutation 'foo.to_int'
  mutation 'Integer(foo)'
end

Mutant::Meta::Example.add do
  source 'foo.to_h'

  singleton_mutations
  mutation 'foo'
  mutation 'self.to_h'
  mutation 'foo.to_hash'
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
  source 'foo.is_a?(bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'bar'
  mutation 'foo.is_a?'
  mutation 'foo.is_a?(nil)'
  mutation 'foo.is_a?(self)'
  mutation 'self.is_a?(bar)'
  mutation 'foo.instance_of?(bar)'
end

Mutant::Meta::Example.add do
  source 'foo.is_a?(bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'bar'
  mutation 'foo.is_a?'
  mutation 'foo.is_a?(nil)'
  mutation 'foo.is_a?(self)'
  mutation 'self.is_a?(bar)'
  mutation 'foo.instance_of?(bar)'
end

Mutant::Meta::Example.add do
  source 'foo.kind_of?(bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'bar'
  mutation 'foo.kind_of?'
  mutation 'foo.kind_of?(nil)'
  mutation 'foo.kind_of?(self)'
  mutation 'self.kind_of?(bar)'
  mutation 'foo.instance_of?(bar)'
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
  mutation 'self.gsub(a, b)'
end

Mutant::Meta::Example.add do
  source 'foo.values_at(a, b)'

  singleton_mutations
  mutation 'foo.fetch_values(a, b)'
  mutation 'foo'
  mutation 'self.values_at(a, b)'
  mutation 'foo.values_at(a)'
  mutation 'foo.values_at(b)'
  mutation 'foo.values_at(nil, b)'
  mutation 'foo.values_at(self, b)'
  mutation 'foo.values_at(a, nil)'
  mutation 'foo.values_at(a, self)'
  mutation 'foo.values_at'
end

Mutant::Meta::Example.add do
  source 'foo.__send__(bar)'

  singleton_mutations
  mutation 'foo.__send__'
  mutation 'foo.public_send(bar)'
  mutation 'bar'
  mutation 'foo'
  mutation 'self.__send__(bar)'
  mutation 'foo.__send__(nil)'
  mutation 'foo.__send__(self)'
end

Mutant::Meta::Example.add do
  source 'foo.send(bar)'

  singleton_mutations
  mutation 'foo.send'
  mutation 'foo.public_send(bar)'
  mutation 'foo.__send__(bar)'
  mutation 'bar'
  mutation 'foo'
  mutation 'self.send(bar)'
  mutation 'foo.send(nil)'
  mutation 'foo.send(self)'
end

Mutant::Meta::Example.add do
  source 'self.bar = baz'

  singleton_mutations
  mutation 'self.bar = nil'
  mutation 'self.bar = self'
  mutation 'self.bar'
  mutation 'baz'
  # This one could probably be removed
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
end

Mutant::Meta::Example.add do
  source 'foo[bar] = baz'

  singleton_mutations
  mutation 'foo'
  mutation 'foo[bar]'
  mutation 'foo[bar] = self'
  mutation 'foo[bar] = nil'
  mutation 'foo[nil] = baz'
  mutation 'foo[self] = baz'
  mutation 'foo[] = baz'
  mutation 'baz'
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
  source 'foo'

  singleton_mutations
end

Mutant::Meta::Example.add do
  source 'self.foo'

  singleton_mutations
  mutation 'foo'
end

Unparser::Constants::KEYWORDS.each do |keyword|
  Mutant::Meta::Example.add do
    source "self.#{keyword}"

    singleton_mutations
  end
end

Mutant::Meta::Example.add do
  source 'foo.bar'

  singleton_mutations
  mutation 'foo'
  mutation 'self.bar'
end

Mutant::Meta::Example.add do
  source 'self.class.foo'

  singleton_mutations
  mutation 'self.class'
  mutation 'self.foo'
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
end

Mutant::Meta::Example.add do
  source 'self.fetch(nil)'

  singleton_mutations
  mutation 'self.fetch'
  mutation 'fetch(nil)'
  mutation 'self.key?(nil)'
end

Unparser::Constants::KEYWORDS.each do |keyword|
  Mutant::Meta::Example.add do
    source "foo.#{keyword}(nil)"

    singleton_mutations
    mutation "self.#{keyword}(nil)"
    mutation "foo.#{keyword}"
    mutation 'foo'
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

Mutant::Meta::Example.add do
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

Mutant::Meta::Example.add do
  source 'self.foo[]'

  singleton_mutations
  mutation 'self.foo'
  mutation 'self.foo.at()'
  mutation 'self.foo.fetch()'
  mutation 'self.foo.key?()'
  mutation 'self[]'
  mutation 'foo[]'
end

Mutant::Meta::Example.add do
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

Mutant::Meta::Example.add do
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

(Mutant::AST::Types::BINARY_METHOD_OPERATORS - %i[<= >= < > == != eql?]).each do |operator|
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

Mutant::Meta::Example.add do
  source 'a != b'

  singleton_mutations
  mutation 'nil != b'
  mutation 'self != b'
  mutation 'a'
  mutation 'b'
  mutation 'a != nil'
  mutation 'a != self'
  mutation '!a.eql?(b)'
  mutation '!a.equal?(b)'
end
