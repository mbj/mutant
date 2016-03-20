Mutant::Meta::Example.add :block do
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

Mutant::Meta::Example.add :block do
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

Mutant::Meta::Example.add :block do
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

Mutant::Meta::Example.add :block do
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

Mutant::Meta::Example.add :block do
  source 'foo { |(a)| }'

  singleton_mutations
  mutation 'foo { || }'
  mutation 'foo { |a| }'
  mutation 'foo { |(a)| raise }'
  mutation 'foo { |(_a)| }'
  mutation 'foo'
end

Mutant::Meta::Example.add :block do
  source 'foo { bar(nil) }'

  singleton_mutations
  mutation 'foo'
  mutation 'foo { bar }'
  mutation 'foo { nil }'
  mutation 'foo {}'
  mutation 'foo { self }'
  mutation 'foo { raise }'
  mutation 'foo.bar(nil)'
  mutation 'bar(nil)'
end

Mutant::Meta::Example.add :block do
  source 'foo { self << true }'

  singleton_mutations
  mutation 'foo { self << false }'
  mutation 'foo { self << nil }'
  mutation 'foo { nil << true }'
  mutation 'foo { nil }'
  mutation 'foo { self }'
  mutation 'foo { true }'
  mutation 'self << true'
  mutation 'foo << true'
  mutation 'foo { raise }'
  mutation 'foo { }'
  mutation 'foo'
end
