Mutant::Meta::Example.add do
  source 'foo { a; b }'

  singleton_mutations
  mutation 'foo { a }'
  mutation 'foo { b }'
  mutation 'foo {}'
  mutation 'foo { raise }'
  mutation 'foo { a; nil }'
  mutation 'foo { a; self }'
  mutation 'foo { nil; b }'
  mutation 'foo { self; b }'
  mutation 'foo'
  mutation 'a; b'
end

Mutant::Meta::Example.add do
  source 'foo { |a, b| }'

  singleton_mutations
  mutation 'foo'
  mutation 'foo { |a, b| raise }'
  mutation 'foo { |a, _b| }'
  mutation 'foo { |_a, b| }'
  mutation 'foo { |a| }'
  mutation 'foo { |b| }'
  mutation 'foo { || }'
end

Mutant::Meta::Example.add do
  source 'foo { |(a, b), c| }'

  singleton_mutations
  mutation 'foo { || }'
  mutation 'foo { |a, b, c| }'
  mutation 'foo { |(a, b), c| raise }'
  mutation 'foo { |(a), c| }'
  mutation 'foo { |(b), c| }'
  mutation 'foo { |(a, b)| }'
  mutation 'foo { |c| }'
  mutation 'foo { |(_a, b), c| }'
  mutation 'foo { |(a, _b), c| }'
  mutation 'foo { |(a, b), _c| }'
  mutation 'foo'
end

Mutant::Meta::Example.add do
  source 'foo(a, b) {}'

  singleton_mutations
  mutation 'foo(a, nil) {}'
  mutation 'foo(nil, b) {}'
  mutation 'foo(self, b) {}'
  mutation 'foo(a, self) {}'
  mutation 'foo(a, b)'
  mutation 'foo(a, b) { raise }'
  mutation 'foo(a) {}'
  mutation 'foo(b) {}'
  mutation 'foo {}'
end

Mutant::Meta::Example.add do
  source 'foo { |(a)| }'

  singleton_mutations
  mutation 'foo { || }'
  mutation 'foo { |a| }'
  mutation 'foo { |(a)| raise }'
  mutation 'foo { |(_a)| }'
  mutation 'foo'
end

Mutant::Meta::Example.add do
  source 'self.foo { bar(nil) }'

  singleton_mutations
  mutation 'self.foo'
  mutation 'foo { bar(nil) }'
  mutation 'self.foo { bar }'
  mutation 'self.foo { nil }'
  mutation 'self.foo {}'
  mutation 'self.foo { self }'
  mutation 'self.foo { raise }'
  mutation 'bar(nil)'
  mutation 'self.bar(nil)'
end
