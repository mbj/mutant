# encoding: utf-8

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
  mutation 'foo { |a, b__mutant__| }'
  mutation 'foo { |a__mutant__, b| }'
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
  mutation 'foo { |(a__mutant__, b), c| }'
  mutation 'foo { |(a, b__mutant__), c| }'
  mutation 'foo { |(a, b), c__mutant__| }'
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
  mutation 'foo { |(a__mutant__)| }'
  mutation 'foo'
end
