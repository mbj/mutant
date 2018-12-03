# frozen_string_literal: true

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
  source 'A.const_get(bar)'

  singleton_mutations
  mutation 'A.const_get'
  mutation 'A'
  mutation 'bar'
  mutation 'A.const_get(nil)'
  mutation 'A.const_get(self)'
  mutation 'self.const_get(bar)'
end

Mutant::Meta::Example.add :send do
  source 'method(bar)'

  singleton_mutations
  mutation 'public_method(bar)'
  mutation 'method'
  mutation 'bar'
  mutation 'method(nil)'
  mutation 'method(self)'
end

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
  source 'reverse_each'

  singleton_mutations
  mutation 'each'
end

Mutant::Meta::Example.add :send do
  source 'reverse_merge'

  singleton_mutations
  mutation 'merge'
end

Mutant::Meta::Example.add :send do
  source 'reverse_map'

  singleton_mutations
  mutation 'map'
  mutation 'each'
end

Mutant::Meta::Example.add :send do
  source 'map'

  singleton_mutations
  mutation 'each'
end

Mutant::Meta::Example.add :send do
  source 'flat_map'

  singleton_mutations
  mutation 'map'
end

Mutant::Meta::Example.add :send do
  source 'to_i'

  singleton_mutations
  mutation 'to_int'
end

Mutant::Meta::Example.add :send do
  source 'foo.to_s'

  singleton_mutations
  mutation 'foo'
  mutation 'self.to_s'
  mutation 'foo.to_str'
end

Mutant::Meta::Example.add :send do
  source 'foo.to_a'

  singleton_mutations
  mutation 'foo'
  mutation 'self.to_a'
  mutation 'foo.to_ary'
  mutation 'foo.to_set'
end

Mutant::Meta::Example.add :send do
  source 'foo.to_i'

  singleton_mutations
  mutation 'foo'
  mutation 'self.to_i'
  mutation 'foo.to_int'
  mutation 'Integer(foo)'
end

Mutant::Meta::Example.add :send do
  source 'foo.to_h'

  singleton_mutations
  mutation 'foo'
  mutation 'self.to_h'
  mutation 'foo.to_hash'
end

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
  source 'foo.dig(a, b)'

  singleton_mutations
  mutation 'foo.fetch(a).dig(b)'
  mutation 'foo'
  mutation 'self.dig(a, b)'
  mutation 'foo.dig(a)'
  mutation 'foo.dig(b)'
  mutation 'foo.dig(nil, b)'
  mutation 'foo.dig(self, b)'
  mutation 'foo.dig(a, nil)'
  mutation 'foo.dig(a, self)'
  mutation 'foo.dig'
end

Mutant::Meta::Example.add :send do
  source 'foo.dig(a)'

  singleton_mutations
  mutation 'foo.fetch(a)'
  mutation 'foo'
  mutation 'self.dig(a)'
  mutation 'foo.dig(nil)'
  mutation 'foo.dig(self)'
  mutation 'foo.dig'
  mutation 'a'
end

Mutant::Meta::Example.add :send do
  source 'foo.dig'

  singleton_mutations
  mutation 'foo'
  mutation 'self.dig'
end

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
  source 'self.booz = baz'

  singleton_mutations
  mutation 'self.booz = nil'
  mutation 'self.booz = self'
  mutation 'self.booz'
  mutation 'baz'
end

Mutant::Meta::Example.add :send do
  source 'foo.booz = baz'

  singleton_mutations
  mutation 'foo'
  mutation 'foo.booz = nil'
  mutation 'foo.booz = self'
  mutation 'self.booz = baz'
  mutation 'foo.booz'
  mutation 'baz'
end

Mutant::Meta::Example.add :send do
  source 'foo(*bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'foo(nil)'
  mutation 'foo(bar)'
  mutation 'foo(self)'
  mutation 'foo(*nil)'
  mutation 'foo(*self)'
end

Mutant::Meta::Example.add :send do
  source 'foo(&bar)'

  singleton_mutations
  mutation 'foo'
end

Mutant::Meta::Example.add :send do
  source 'foo'

  singleton_mutations
end

Mutant::Meta::Example.add :send do
  source 'self.foo'

  singleton_mutations
  mutation 'foo'
end

Unparser::Constants::KEYWORDS.each do |keyword|
  Mutant::Meta::Example.add :send do
    source "self.#{keyword}"

    singleton_mutations
  end
end

Mutant::Meta::Example.add :send do
  source 'foo.bar'

  singleton_mutations
  mutation 'foo'
  mutation 'self.bar'
end

Mutant::Meta::Example.add :send do
  source 'self.class.foo'

  singleton_mutations
  mutation 'self.class'
  mutation 'self.foo'
end

Mutant::Meta::Example.add :send do
  source 'foo(nil)'

  singleton_mutations
  mutation 'foo'
end

Mutant::Meta::Example.add :send do
  source 'self.foo(nil)'

  singleton_mutations
  mutation 'self.foo'
  mutation 'foo(nil)'
end

Mutant::Meta::Example.add :send do
  source 'self.fetch(nil)'

  singleton_mutations
  mutation 'self.fetch'
  mutation 'fetch(nil)'
  mutation 'self.key?(nil)'
end

Unparser::Constants::KEYWORDS.each do |keyword|
  Mutant::Meta::Example.add :send do
    source "foo.#{keyword}(nil)"

    singleton_mutations
    mutation "self.#{keyword}(nil)"
    mutation "foo.#{keyword}"
    mutation 'foo'
  end
end

Mutant::Meta::Example.add :send do
  source 'foo(nil, nil)'

  singleton_mutations
  mutation 'foo()'
  mutation 'foo(nil)'
end

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
  source 'foo(n..-1)'

  singleton_mutations
  mutation 'foo'
  mutation 'n..-1'
  mutation 'foo(nil)'
  mutation 'foo(self)'
  mutation 'foo(n...-1)'
  mutation 'foo(nil..-1)'
  mutation 'foo(self..-1)'
  mutation 'foo(n..nil)'
  mutation 'foo(n..self)'
  mutation 'foo(n..0)'
  mutation 'foo(n..1)'
  mutation 'foo(n..-2)'
end

(Mutant::AST::Types::BINARY_METHOD_OPERATORS - %i[=~ <= >= < > == != eql?]).each do |operator|
  Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
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

Mutant::Meta::Example.add :send do
  source 'sample'

  singleton_mutations
  mutation 'first'
  mutation 'last'
end

Mutant::Meta::Example.add :send do
  source 'pop'

  singleton_mutations
  mutation 'last'
end

Mutant::Meta::Example.add :send do
  source 'shift'

  singleton_mutations
  mutation 'first'
end

Mutant::Meta::Example.add :send do
  source 'first'

  singleton_mutations
  mutation 'last'
end

Mutant::Meta::Example.add :send do
  source 'last'

  singleton_mutations
  mutation 'first'
end

Mutant::Meta::Example.add :send do
  source '!!foo'

  singleton_mutations
  mutation '!foo'
  mutation '!self'
  mutation '!!self'
  mutation 'foo'
end

Mutant::Meta::Example.add :send do
  source '!foo'

  singleton_mutations
  mutation 'foo'
  mutation '!self'
end

Mutant::Meta::Example.add :send do
  source '!foo&.!'

  singleton_mutations
  mutation 'foo&.!'
  mutation '!self'
  mutation '!foo'
  mutation '!self&.!'
  mutation '!(!foo)'
end

Mutant::Meta::Example.add :send do
  source 'custom.proc { }'

  singleton_mutations
  mutation 'custom.proc'
  mutation 'custom { }'
  mutation 'self.proc { }'
  mutation 'custom.proc { raise }'
end

Mutant::Meta::Example.add :send do
  source 'proc { }'

  singleton_mutations
  mutation 'proc'
  mutation 'proc { raise }'
  mutation 'lambda { }'
end

Mutant::Meta::Example.add :send do
  source 'Proc.new { }'

  singleton_mutations
  mutation 'Proc.new'
  mutation 'self.new { }'
  mutation 'Proc.new { raise }'
  mutation 'lambda { }'
end

Mutant::Meta::Example.add :send do
  source 'a =~ //'

  singleton_mutations
  mutation 'a'
  mutation 'nil =~ //'
  mutation 'self =~ //'
  mutation '//'
  mutation 'a =~ /nomatch\A/'
  mutation 'a.match?(//)'
end

Mutant::Meta::Example.add :send do
  source '//.match(a)'

  singleton_mutations
  mutation 'a'
  mutation '//.match'
  mutation '//.match(nil)'
  mutation '//.match(self)'
  mutation '//.match?(a)'
  mutation '//'
  mutation '/nomatch\A/.match(a)'
end
