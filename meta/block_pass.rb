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
