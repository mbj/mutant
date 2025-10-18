# frozen_string_literal: true

Mutant::Meta::Example.add :procarg0 do
  source 'foo { |a| }'

  singleton_mutations
  mutation 'foo { |a| raise }'
  mutation 'foo'
end

Mutant::Meta::Example.add :procarg0 do
  source 'foo { |(a)| }'

  singleton_mutations
  mutation 'foo { |(a)| raise }'
  mutation 'foo'
end

Mutant::Meta::Example.add :procarg0 do
  source 'foo { |(a, b)| }'

  singleton_mutations
  mutation 'foo { |a, b| }'
  mutation 'foo { |(a, b)| raise }'
  mutation 'foo'
end

Mutant::Meta::Example.add :procarg0 do
  source 'foo { |(*)| }'

  singleton_mutations
  mutation 'foo { |(*)| raise }'
  mutation 'foo'
end

Mutant::Meta::Example.add :procarg0 do
  source 'foo { |(a, (*))| }'

  singleton_mutations
  mutation 'foo { |a, (*)| }'
  mutation 'foo { |(a, (*))| raise }'
  mutation 'foo'
end
