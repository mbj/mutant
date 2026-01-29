# frozen_string_literal: true

Mutant::Meta::Example.add :send do
  source 'a > b'

  singleton_mutations
  mutation 'a == b'
  mutation 'a.eql?(b)'
  mutation 'a.equal?(b)'
  mutation 'nil > b'
  mutation 'a > nil'
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
  mutation 'self.const_get(bar)'
end

Mutant::Meta::Example.add :send do
  source 'method(bar)'

  singleton_mutations
  mutation 'public_method(bar)'
  mutation 'method'
  mutation 'bar'
  mutation 'method(nil)'
end

Mutant::Meta::Example.add :send do
  source 'a >= b'

  singleton_mutations
  mutation 'a > b'
  mutation 'a == b'
  mutation 'a.eql?(b)'
  mutation 'a.equal?(b)'
  mutation 'nil >= b'
  mutation 'a >= nil'
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
  mutation 'a <= nil'
  mutation 'a'
  mutation 'b'
end

Mutant::Meta::Example.add :send do
  source 'a < b'

  singleton_mutations
  mutation 'a == b'
  mutation 'a.eql?(b)'
  mutation 'a.equal?(b)'
  mutation 'nil < b'
  mutation 'a < nil'
  mutation 'a'
  mutation 'b'
end

Mutant::Meta::Example.add :send do
  source 'all?'

  singleton_mutations
  mutation 'any?'
  mutation 'false'
  mutation 'true'
end

Mutant::Meta::Example.add :send do
  source 'any?'

  singleton_mutations
  mutation 'all?'
  mutation 'false'
  mutation 'true'
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

Mutant::Meta::Example.add :send, operators: :full do
  source 'foo == bar'

  singleton_mutations
  mutation 'foo'
  mutation 'bar'
  mutation 'nil == bar'
  mutation 'foo == nil'
  mutation 'foo != bar'
  mutation 'foo.eql?(bar)'
  mutation 'foo.equal?(bar)'
end

Mutant::Meta::Example.add :send, operators: :light do
  source 'foo == bar'

  singleton_mutations
  mutation 'foo'
  mutation 'bar'
  mutation 'nil == bar'
  mutation 'foo == nil'
end

Mutant::Meta::Example.add :send do
  source 'foo.is_a?(bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'bar'
  mutation 'foo.is_a?'
  mutation 'foo.is_a?(nil)'
  mutation 'self.is_a?(bar)'
  mutation 'foo.instance_of?(bar)'
  mutation 'false'
  mutation 'true'
end

Mutant::Meta::Example.add :send do
  source 'foo.kind_of?(bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'bar'
  mutation 'foo.kind_of?'
  mutation 'foo.kind_of?(nil)'
  mutation 'self.kind_of?(bar)'
  mutation 'foo.instance_of?(bar)'
  mutation 'false'
  mutation 'true'
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
  mutation 'foo.gsub(nil, b)'
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
  mutation 'foo.values_at(a, nil)'
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
  mutation 'foo.dig(a, nil)'
  mutation 'foo.dig'
end

Mutant::Meta::Example.add :send do
  source 'foo.dig(a)'

  singleton_mutations
  mutation 'foo.fetch(a)'
  mutation 'foo'
  mutation 'self.dig(a)'
  mutation 'foo.dig(nil)'
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
end

Mutant::Meta::Example.add :send do
  source '__send__(:foo)'

  singleton_mutations
  mutation 'foo'
  mutation '__send__'
  mutation 'public_send(:foo)'
  mutation ':foo'
  mutation '__send__(nil)'
  mutation '__send__(:foo__mutant__)'
end

Mutant::Meta::Example.add :send do
  source 'foo.send(:bar)'

  singleton_mutations
  mutation 'foo.bar'
  mutation 'foo.send'
  mutation 'foo.__send__(:bar)'
  mutation 'foo.public_send(:bar)'
  mutation 'foo'
  mutation ':bar'
  mutation 'self.send(:bar)'
  mutation 'foo.send(nil)'
  mutation 'foo.send(:bar__mutant__)'
end

Mutant::Meta::Example.add :send do
  source 'send'

  singleton_mutations

  mutation '__send__'
  mutation 'public_send'
end

Mutant::Meta::Example.add :send do
  source 'foo.public_send(:bar, 1, two: true, **kwargs, &block)'

  singleton_mutations
  mutation 'foo.public_send(:bar, 1, two: true, **kwargs, &nil)'
  mutation 'foo.bar(1, two: true, **kwargs, &block)'
  mutation 'foo'
  mutation 'self.public_send(:bar, 1, two: true, **kwargs, &block)'
  mutation 'foo.public_send'
  mutation 'foo.public_send(nil, 1, two: true, **kwargs, &block)'
  mutation 'foo.public_send(:bar__mutant__, 1, two: true, **kwargs, &block)'
  mutation 'foo.public_send(1, two: true, **kwargs, &block)'
  mutation 'foo.public_send(:bar, nil, two: true, **kwargs, &block)'
  mutation 'foo.public_send(:bar, 0, two: true, **kwargs, &block)'
  mutation 'foo.public_send(:bar, 2, two: true, **kwargs, &block)'
  mutation 'foo.public_send(:bar, two: true, **kwargs, &block)'
  mutation 'foo.public_send(:bar, 1, two__mutant__: true, **kwargs, &block)'
  mutation 'foo.public_send(:bar, 1, two: false, **kwargs, &block)'
  mutation 'foo.public_send(:bar, 1, **kwargs, &block)'
  mutation 'foo.public_send(:bar, 1, two: true, **nil, &block)'
  mutation 'foo.public_send(:bar, 1, two: true, &block)'
  mutation 'foo.public_send(:bar, 1, &block)'
  mutation 'foo.public_send(:bar, 1, two: true, **kwargs)'
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
end

Mutant::Meta::Example.add :send do
  source 'self.booz = baz'

  singleton_mutations
  mutation 'self'
  mutation 'self.booz = nil'
  mutation 'self.booz'
  mutation 'baz'
end

Mutant::Meta::Example.add :send do
  source 'foo.booz = baz'

  singleton_mutations
  mutation 'foo'
  mutation 'foo.booz = nil'
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
  mutation 'foo(*nil)'
end

Mutant::Meta::Example.add :send do
  source 'foo(&bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'foo(&nil)'
end

Mutant::Meta::Example.add :send do
  source 'foo'

  singleton_mutations
end

Mutant::Meta::Example.add :send do
  source 'self.foo'

  singleton_mutations
  mutation 'self'
  mutation 'foo'
end

Unparser::Constants::KEYWORDS.each do |keyword|
  Mutant::Meta::Example.add :send do
    source "self.#{keyword}"

    singleton_mutations
    mutation 'self'
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
  mutation 'self'
  mutation 'self.foo'
  mutation 'foo(nil)'
end

Mutant::Meta::Example.add :send do
  source 'self.fetch(nil)'

  singleton_mutations
  mutation 'self'
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
  source '(left - right) + foo'

  singleton_mutations
  mutation 'foo'
  mutation '(left - right)'
  mutation '(left) + foo'
  mutation '(right) + foo'
  mutation '(left - right) + nil'
  mutation '(left - nil) + foo'
  mutation '(nil - right) + foo'
  mutation '(nil) + foo'
  # Arithmetic operator mutations
  mutation '(left - right) - foo'
  mutation '(left + right) + foo'
end

Mutant::Meta::Example.add :send do
  source 'foo(n..-1)'

  singleton_mutations
  mutation 'foo'
  mutation 'n..-1'
  mutation 'foo(nil)'
  mutation 'foo(n...-1)'
  mutation 'foo(nil..-1)'
  mutation 'foo(n..nil)'
  mutation 'foo(n..0)'
  mutation 'foo(n..1)'
  mutation 'foo(n..-2)'
end

excluded_operators = %i[=~ <= >= < > == === != eql? & | ^ << >> + - * / % **]
(Mutant::AST::Types::BINARY_METHOD_OPERATORS - excluded_operators).each do |operator|
  Mutant::Meta::Example.add :send do
    source "true #{operator} false"

    singleton_mutations
    mutation 'true'
    mutation 'false'
    mutation "false #{operator} false"
    mutation "true  #{operator} true"
  end
end

# Addition operator
Mutant::Meta::Example.add :send do
  source 'a + b'

  singleton_mutations
  mutation 'a'
  mutation 'b'
  mutation 'nil + b'
  mutation 'a + nil'
  mutation 'a - b'
end

# Subtraction operator
Mutant::Meta::Example.add :send do
  source 'a - b'

  singleton_mutations
  mutation 'a'
  mutation 'b'
  mutation 'nil - b'
  mutation 'a - nil'
  mutation 'a + b'
end

# Bitwise AND operator
Mutant::Meta::Example.add :send do
  source 'a & b'

  singleton_mutations
  mutation 'a'
  mutation 'b'
  mutation 'nil & b'
  mutation 'a & nil'
  mutation 'a | b'
  mutation 'a ^ b'
end

# Bitwise OR operator
Mutant::Meta::Example.add :send do
  source 'a | b'

  singleton_mutations
  mutation 'a'
  mutation 'b'
  mutation 'nil | b'
  mutation 'a | nil'
  mutation 'a & b'
  mutation 'a ^ b'
end

# Bitwise XOR operator
Mutant::Meta::Example.add :send do
  source 'a ^ b'

  singleton_mutations
  mutation 'a'
  mutation 'b'
  mutation 'nil ^ b'
  mutation 'a ^ nil'
  mutation 'a & b'
  mutation 'a | b'
end

# Left shift operator
Mutant::Meta::Example.add :send do
  source 'a << b'

  singleton_mutations
  mutation 'a'
  mutation 'b'
  mutation 'nil << b'
  mutation 'a << nil'
  mutation 'a >> b'
end

# Right shift operator
Mutant::Meta::Example.add :send do
  source 'a >> b'

  singleton_mutations
  mutation 'a'
  mutation 'b'
  mutation 'nil >> b'
  mutation 'a >> nil'
  mutation 'a << b'
end

# Exponentiation operator
Mutant::Meta::Example.add :send do
  source 'a ** b'

  singleton_mutations
  mutation 'a'
  mutation 'b'
  mutation 'nil ** b'
  mutation 'a ** nil'
  mutation 'a * b'
end

# Modulo operator
Mutant::Meta::Example.add :send do
  source 'a % b'

  singleton_mutations
  mutation 'a'
  mutation 'b'
  mutation 'nil % b'
  mutation 'a % nil'
  mutation 'a / b'
end

Mutant::Meta::Example.add :send do
  source 'a != b'

  singleton_mutations
  mutation 'nil != b'
  mutation 'a'
  mutation 'b'
  mutation 'a != nil'
  mutation 'a == b'
  mutation '!a.eql?(b)'
  mutation '!a.equal?(b)'
end

Mutant::Meta::Example.add :send do
  source '!!foo'

  singleton_mutations
  mutation '!foo'
  mutation 'foo'
end

Mutant::Meta::Example.add :send do
  source '!foo'

  singleton_mutations
  mutation 'foo'
end

# Unary minus (negation removal)
Mutant::Meta::Example.add :send do
  source '-foo'

  singleton_mutations
  mutation 'foo'
end

# Unary plus (removal)
Mutant::Meta::Example.add :send do
  source '+foo'

  singleton_mutations
  mutation 'foo'
end

Mutant::Meta::Example.add :send do
  source '!foo&.!'

  singleton_mutations
  mutation 'foo&.!'
  mutation '!foo'
  mutation '!!foo'
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
  mutation '//'
  mutation 'a =~ /nomatch\A/'
  mutation 'a.match?(//)'
end

Mutant::Meta::Example.add :send do
  source '//.match(a)'

  singleton_mutations
  mutation 'a'
  mutation 'self.match(a)'
  mutation '//.match'
  mutation '//.match(nil)'
  mutation '//'
  mutation '/nomatch\A/.match(a)'
  mutation '//.match?(a)'
end

Mutant::Meta::Example.add :send do
  source 'foo(bar { nil; nil })'

  singleton_mutations
  mutation 'bar { nil; nil }'
  mutation 'foo'
  mutation 'foo(bar { nil })'
  mutation 'foo(bar { raise })'
  mutation 'foo(bar {})'
  mutation 'foo(bar)'
  mutation 'foo(nil)'
end

Mutant::Meta::Example.add :send do
  source 'Array(a)'

  singleton_mutations
  mutation 'a'
  mutation 'Array()'
  mutation 'Array(nil)'
  mutation '[a]'
end

Mutant::Meta::Example.add :send do
  source 'Kernel.Array(a)'

  singleton_mutations
  mutation 'a'
  mutation 'Kernel'
  mutation 'self.Array(a)'
  mutation 'Kernel.Array'
  mutation 'Kernel.Array(nil)'
  mutation '[a]'
end

Mutant::Meta::Example.add :send do
  source 'foo.Array(a)'

  singleton_mutations
  mutation 'a'
  mutation 'self.Array(a)'
  mutation 'foo'
  mutation 'foo.Array'
  mutation 'foo.Array(nil)'
end

Mutant::Meta::Example.add :send do
  source 'foo(a: nil)'

  singleton_mutations

  mutation 'foo'
  mutation 'foo(a__mutant__: nil)'
end

Mutant::Meta::Example.add :send do
  source 'a === b'

  singleton_mutations

  mutation 'a'
  mutation 'b'
  mutation 'nil === b'
  mutation 'a === nil'
  mutation 'a.is_a?(b)'
end

Mutant::Meta::Example.add :send do
  source 'a.match?(/\Afoo/)'

  singleton_mutations

  mutation 'a'
  mutation 'a.match?'
  mutation '/\Afoo/'
  mutation 'self.match?(/\Afoo/)'
  mutation 'a.match?(//)'
  mutation 'a.match?(/nomatch\A/)'
  mutation "a.start_with?('foo')"
  mutation 'false'
  mutation 'true'
end

Mutant::Meta::Example.add :send do
  source 'a.match?(/\Afoo#{}/)'

  singleton_mutations

  mutation 'a'
  mutation 'a.match?'
  mutation 'a.match?(//)'
  mutation 'a.match?(/nomatch\A/)'
  mutation '/\Afoo#{}/'
  mutation 'self.match?(/\Afoo#{}/)'
  mutation 'false'
  mutation 'true'
end

Mutant::Meta::Example.add :send do
  source 'match(/\A\d/)'

  singleton_mutations

  mutation 'match'
  mutation '/\A\d/'
  mutation 'match?(/\A\d/)'
  mutation 'match(/\A\D/)'
  mutation 'match(//)'
  mutation 'match(/nomatch\A/)'
end

Mutant::Meta::Example.add :send do
  source 'a =~ /\Afoo/'

  singleton_mutations

  mutation 'a'
  mutation 'nil =~ /\Afoo/'
  mutation '/\Afoo/'
  mutation 'a =~ //'
  mutation 'a =~ /nomatch\A/'
  mutation 'a.match?(/\Afoo/)'
end

Mutant::Meta::Example.add :send do
  source 'match?(/\Afoo/, 1)'

  singleton_mutations

  mutation 'match?(/\Afoo/)'
  mutation 'match?(1)'
  mutation 'match?(/\Afoo/, nil)'
  mutation 'match?(/\Afoo/, 0)'
  mutation 'match?(/\Afoo/, 2)'
  mutation 'match?'
  mutation 'match?(//, 1)'
  mutation 'match?(/nomatch\A/, 1)'
  mutation 'false'
  mutation 'true'
end

Mutant::Meta::Example.add :send do
  source 'foo(/\Abar/)'

  singleton_mutations

  mutation 'foo'
  mutation '/\Abar/'
  mutation 'foo(//)'
  mutation 'foo(/nomatch\A/)'
end

Mutant::Meta::Example.add :send do
  source 'a.match(/foo\z/)'

  singleton_mutations

  mutation 'a.match?(/foo\z/)'
  mutation 'a.match'
  mutation 'a'
  mutation '/foo\z/'
  mutation 'a.match(//)'
  mutation 'a.match(/nomatch\A/)'
  mutation 'self.match(/foo\z/)'
  mutation "a.end_with?('foo')"
end

Mutant::Meta::Example.add :send do
  source <<~'RUBY'
    a.match?(/(?:
    )/)
  RUBY

  singleton_mutations

  mutation 'a'

  mutation <<~'RUBY'
    /(?:
    )/
  RUBY

  mutation <<~'RUBY'
    self.match?(/(?:
    )/)
  RUBY

  mutation <<~'RUBY'
    a.match?
  RUBY

  mutation 'false'
  mutation 'true'
  mutation 'a.match?(//)'
  mutation 'a.match?(/nomatch\A/)'
end

Mutant::Meta::Example.add :send do
  source 'nil.to_f'

  mutation 'nil'
end

Mutant::Meta::Example.add :send do
  source 'a.reduce(:+)'

  singleton_mutations

  mutation 'a'
  mutation 'self.reduce(:+)'
  mutation 'a.reduce'
  mutation 'a.reduce(nil)'
  mutation 'a.reduce(:"+__mutant__")'
  mutation ':+'
  mutation 'a.sum'
end

Mutant::Meta::Example.add :send do
  source 'a.reduce(INITIAL, &:+)'

  singleton_mutations

  mutation 'a'
  mutation 'a.reduce'
  mutation 'a.reduce(nil, &:+)'
  mutation 'a.reduce(INITIAL, &nil)'
  mutation 'a.reduce(INITIAL)'
  mutation 'a.reduce(&:+)'
  mutation 'self.reduce(INITIAL, &:+)'
  mutation 'a.reduce(INITIAL, &:"+__mutant__")'
  mutation 'a.sum(INITIAL)'
  # Arithmetic operator mutations for block_pass symbol
  mutation 'a.reduce(INITIAL, &:-)'
end

Mutant::Meta::Example.add :send do
  source 'reduce(:*)'

  singleton_mutations

  mutation 'reduce'
  mutation ':*'
  mutation 'reduce(nil)'
  mutation 'reduce(:"*__mutant__")'
end

Mutant::Meta::Example.add :send do
  source 'foo(:+)'

  singleton_mutations

  mutation 'foo'
  mutation ':+'
  mutation 'foo(nil)'
  mutation 'foo(:"+__mutant__")'
end

Mutant::Meta::Example.add :send, operators: :light do
  source 'first'

  singleton_mutations
end

Mutant::Meta::Example.add :send, operators: :light do
  source 'last'

  singleton_mutations
end

Mutant::Meta::Example.add :send, operators: :full do
  source 'first'

  singleton_mutations

  mutation 'last'
end

Mutant::Meta::Example.add :send, operators: :full do
  source 'last'

  singleton_mutations

  mutation 'first'
end

%w[detect find max max_by min min_by].each do |selector|
  Mutant::Meta::Example.add :send do
    source selector

    singleton_mutations

    mutation 'first'
    mutation 'last'
  end

  Mutant::Meta::Example.add :send do
    source "#{selector}(&:block)"

    singleton_mutations

    mutation "#{selector}(&:block__mutant__)"
    mutation "#{selector}(&nil)"
    mutation 'first(&:block)'
    mutation 'last(&:block)'
    mutation selector
  end
end

# Keyword argument removal mutations - tests that explicit values aren't just relying on defaults
Mutant::Meta::Example.add :send do
  source 'foo(bar: 1, baz: 2)'

  singleton_mutations

  # Key mutations
  mutation 'foo(bar__mutant__: 1, baz: 2)'
  mutation 'foo(bar: 1, baz__mutant__: 2)'

  # Value mutations
  mutation 'foo(bar: nil, baz: 2)'
  mutation 'foo(bar: 0, baz: 2)'
  mutation 'foo(bar: 2, baz: 2)'
  mutation 'foo(bar: 1, baz: nil)'
  mutation 'foo(bar: 1, baz: 0)'
  mutation 'foo(bar: 1, baz: 1)'
  mutation 'foo(bar: 1, baz: 3)'

  # Keyword argument removal - tests defaults are properly handled
  mutation 'foo(baz: 2)'
  mutation 'foo(bar: 1)'

  # Remove all keyword arguments
  mutation 'foo'
end

# Bang to non-bang mutations - simple sends without blocks
Mutant::Meta::Example.add :send do
  source 'array.sort!'

  singleton_mutations
  mutation 'array.sort'
  mutation 'array'
  mutation 'self.sort!'
end

Mutant::Meta::Example.add :send do
  source 'array.reverse!'

  singleton_mutations
  mutation 'array.reverse'
  mutation 'array'
  mutation 'self.reverse!'
end

Mutant::Meta::Example.add :send do
  source 'array.flatten!'

  singleton_mutations
  mutation 'array.flatten'
  mutation 'array'
  mutation 'self.flatten!'
end

Mutant::Meta::Example.add :send do
  source 'array.compact!'

  singleton_mutations
  mutation 'array.compact'
  mutation 'array'
  mutation 'self.compact!'
end

Mutant::Meta::Example.add :send do
  source 'array.uniq!'

  singleton_mutations
  mutation 'array.uniq'
  mutation 'array'
  mutation 'self.uniq!'
end

Mutant::Meta::Example.add :send do
  source 'array.shuffle!'

  singleton_mutations
  mutation 'array.shuffle'
  mutation 'array'
  mutation 'self.shuffle!'
end

Mutant::Meta::Example.add :send do
  source 'str.strip!'

  singleton_mutations
  mutation 'str.strip'
  mutation 'str'
  mutation 'self.strip!'
end

Mutant::Meta::Example.add :send do
  source 'str.chomp!'

  singleton_mutations
  mutation 'str.chomp'
  mutation 'str'
  mutation 'self.chomp!'
end

Mutant::Meta::Example.add :send do
  source 'str.upcase!'

  singleton_mutations
  mutation 'str.upcase'
  mutation 'str'
  mutation 'self.upcase!'
end

Mutant::Meta::Example.add :send do
  source 'str.downcase!'

  singleton_mutations
  mutation 'str.downcase'
  mutation 'str'
  mutation 'self.downcase!'
end

Mutant::Meta::Example.add :send do
  source 'hash.merge!(other)'

  singleton_mutations
  mutation 'hash.merge(other)'
  mutation 'hash.merge!'
  mutation 'hash.merge!(nil)'
  mutation 'other'
  mutation 'hash'
  mutation 'self.merge!(other)'
end

# Bang to non-bang mutations with arguments
Mutant::Meta::Example.add :send do
  source 'str.gsub!(pattern, replacement)'

  singleton_mutations
  mutation 'str.gsub(pattern, replacement)'
  mutation 'str.gsub!(pattern)'
  mutation 'str.gsub!(replacement)'
  mutation 'str.gsub!'
  mutation 'str.gsub!(nil, replacement)'
  mutation 'str.gsub!(pattern, nil)'
  mutation 'str'
  mutation 'self.gsub!(pattern, replacement)'
end

Mutant::Meta::Example.add :send do
  source 'str.sub!(pattern, replacement)'

  singleton_mutations
  mutation 'str.sub(pattern, replacement)'
  mutation 'str.sub!(pattern)'
  mutation 'str.sub!(replacement)'
  mutation 'str.sub!'
  mutation 'str.sub!(nil, replacement)'
  mutation 'str.sub!(pattern, nil)'
  mutation 'str'
  mutation 'self.sub!(pattern, replacement)'
end

# Module inclusion mutations
Mutant::Meta::Example.add :send do
  source 'include Foo'

  singleton_mutations
  mutation 'extend(Foo)'
  mutation 'prepend(Foo)'
  mutation 'Foo'
  mutation 'include'
  mutation 'include(nil)'
end

Mutant::Meta::Example.add :send do
  source 'extend Foo'

  singleton_mutations
  mutation 'include(Foo)'
  mutation 'prepend(Foo)'
  mutation 'Foo'
  mutation 'extend'
  mutation 'extend(nil)'
end

Mutant::Meta::Example.add :send do
  source 'prepend Foo'

  singleton_mutations
  mutation 'include(Foo)'
  mutation 'extend(Foo)'
  mutation 'Foo'
  mutation 'prepend'
  mutation 'prepend(nil)'
end
