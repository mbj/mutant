# frozen_string_literal: true

Mutant::Meta::Example.add :block, :lambda do
  source '->() {}'

  singleton_mutations

  mutation '->() { raise }'
end
