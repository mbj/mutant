# frozen_string_literal: true

Mutant::Meta::Example.add :block_pass do
  source 'foo(&bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'foo(&nil)'
  mutation 'foo(&self)'
end

Mutant::Meta::Example.add :block_pass do
  source 'foo(&method(:bar))'

  singleton_mutations
  mutation 'foo'
  mutation 'foo(&nil)'
  mutation 'foo(&self)'
  mutation 'foo(&method)'
  mutation 'foo(&method(nil))'
  mutation 'foo(&method(self))'
  mutation 'foo(&method(:bar__mutant__))'
  mutation 'foo(&public_method(:bar))'
  mutation 'foo(&:bar)'
end
