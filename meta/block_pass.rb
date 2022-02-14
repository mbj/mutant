# frozen_string_literal: true

Mutant::Meta::Example.add :block_pass do
  source 'foo(&bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'foo(&nil)'
end

Mutant::Meta::Example.add :block_pass do
  source 'foo(&method(:bar))'

  singleton_mutations
  mutation 'foo'
  mutation 'foo(&nil)'
  mutation 'foo(&method)'
  mutation 'foo(&method(nil))'
  mutation 'foo(&method(:bar__mutant__))'
  mutation 'foo(&public_method(:bar))'
  mutation 'foo(&:bar)'
end

Mutant::Meta::Example.add :block_pass do
  source 'foo(&:to_s)'

  singleton_mutations
  mutation 'foo'
  mutation 'foo(&nil)'
  mutation 'foo(&:to_str)'
  mutation 'foo(&:to_s__mutant__)'
end

Mutant::Meta::Example.add :block_pass do
  source 'foo(&:bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'foo(&nil)'
  mutation 'foo(&:bar__mutant__)'
end

if RUBY_VERSION >= '3.1'
  Mutant::Meta::Example.add :block_pass do
    source 'def foo(a, &); foo(&); end'

    mutation 'def foo(&); foo(&); end'
    mutation 'def foo(_a, &); foo(&); end'
    mutation 'def foo(a, &); end'
    mutation 'def foo(a, &); foo; end'
    mutation 'def foo(a, &); nil; end'
    mutation 'def foo(a, &); raise; end'
    mutation 'def foo(a, &); super; end'
  end
end
