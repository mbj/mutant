# frozen_string_literal: true

Mutant::Meta::Example.add :block do
  source 'foo { a; b }'

  singleton_mutations
  mutation 'foo { a }'
  mutation 'foo { b }'
  mutation 'foo {}'
  mutation 'foo { raise }'
  mutation 'foo { a; nil }'
  mutation 'foo { nil; b }'
  mutation 'foo'
  mutation 'a; b'
end

Mutant::Meta::Example.add :block do
  source 'foo { |a, b| }'

  singleton_mutations
  mutation 'foo'
  mutation 'foo { |a, b| raise }'
end

Mutant::Meta::Example.add :block do
  source 'foo { |(a, b), c| }'

  singleton_mutations
  mutation 'foo { |a, b, c| }'
  mutation 'foo { |(a, b), c| raise }'
  mutation 'foo'
end

Mutant::Meta::Example.add :block do
  source 'foo(a, b) {}'

  singleton_mutations
  mutation 'foo(a, nil) {}'
  mutation 'foo(nil, b) {}'
  mutation 'foo(a, b)'
  mutation 'foo(a, b) { raise }'
  mutation 'foo(a) {}'
  mutation 'foo(b) {}'
  mutation 'foo {}'
end

Mutant::Meta::Example.add :block do
  source 'foo { |a| }'

  singleton_mutations
  mutation 'foo { |a| raise }'
  mutation 'foo'
end

Mutant::Meta::Example.add :block do
  source 'foo { bar(nil) }'

  singleton_mutations
  mutation 'foo'
  mutation 'foo { bar }'
  mutation 'foo { nil }'
  mutation 'foo {}'
  mutation 'foo { raise }'
  mutation 'foo.bar(nil)'
  mutation 'bar(nil)'
end

Mutant::Meta::Example.add :block do
  source 'foo { |bar| foo(bar) }'

  mutation 'foo { |bar| bar }'
  mutation 'foo { |bar| foo }'
  mutation 'foo { |bar| foo(nil) }'
  mutation 'foo { |bar| nil }'
  mutation 'foo { |bar| raise }'
  mutation 'foo { |bar| }'
  mutation 'foo'
  mutation 'nil'
end

Mutant::Meta::Example.add :block do
  source 'foo { self << true }'

  singleton_mutations
  mutation 'foo { self << false }'
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

Mutant::Meta::Example.add :block do
  source 'foo { next if true }'

  singleton_mutations
  mutation 'foo'
  mutation 'foo { }'
  mutation 'foo { nil }'
  mutation 'foo { raise }'
  mutation 'foo { nil if true }'
  mutation 'foo { break if true }'
  mutation 'foo { next if false }'
  mutation 'foo { next }'
end

Mutant::Meta::Example.add :block do
  source 'foo { next }'

  singleton_mutations
  mutation 'foo { nil }'
  mutation 'foo { raise }'
  mutation 'foo { break }'
  mutation 'foo { }'
  mutation 'foo'
end

Mutant::Meta::Example.add :block do
  source 'foo { break if true }'

  singleton_mutations
  mutation 'foo'
  mutation 'foo { }'
  mutation 'foo { nil }'
  mutation 'foo { raise }'
  mutation 'foo { nil if true }'
  mutation 'foo { break if false }'
  mutation 'foo { break }'
end

Mutant::Meta::Example.add :block do
  source 'foo { break }'

  singleton_mutations
  mutation 'foo { nil }'
  mutation 'foo { raise }'
  mutation 'foo { }'
  mutation 'foo'
end

Mutant::Meta::Example.add :block do
  source 'foo(&:bar).baz {}'

  singleton_mutations

  mutation 'foo(&:bar).baz { raise }'
  mutation 'foo.baz { }'
  mutation 'foo(&:bar).baz'
  mutation 'self.baz {}'
  mutation 'foo(&nil).baz {}'
  mutation 'foo(&:bar__mutant__).baz {}'
end

Mutant::Meta::Example.add :block do
  source 'foo(nil, &:bar).baz {}'

  singleton_mutations
  mutation 'foo(nil, &:bar).baz { raise }'
  mutation 'foo(&:bar).baz { }'
  mutation 'foo(nil).baz { }'
  mutation 'foo.baz { }'
  mutation 'self.baz { }'
  mutation 'foo(nil, &:bar).baz'

  mutation 'foo(nil, &nil).baz {}'
  mutation 'foo(nil, &:bar__mutant__).baz {}'
end

Mutant::Meta::Example.add :block do
  source 'loop { 1 }'

  singleton_mutations
  mutation '1'
  mutation 'loop { 0 }'
  mutation 'loop { 2 }'
  mutation 'loop { raise }'
  mutation 'loop'
end
