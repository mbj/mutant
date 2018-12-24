# frozen_string_literal: true

Mutant::Meta::Example.add :block, :lambda do
  source '->() {}'

  singleton_mutations

  mutation '->() { raise }'
end

Mutant::Meta::Example.add :block, :lambda do
  source '->() { foo.bar }'

  singleton_mutations

  mutation '->() { }'
  mutation '->() { self }'
  mutation '->() { nil }'
  mutation '->() { raise }'
  mutation '->() { self.bar }'
  mutation '->() { foo }'
  mutation 'foo.bar'
end
