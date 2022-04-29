# frozen_string_literal: true

Mutant::Meta::Example.add :procarg0 do
  source 'foo { |a| }'

  singleton_mutations
  mutation 'foo { |a| raise }'
  mutation 'foo { |_a| }'
  mutation 'foo { }'
  mutation 'foo'
end

Mutant::Meta::Example.add :procarg0 do
  source 'foo { |_a| }'

  singleton_mutations
  mutation 'foo { |_a| raise }'
  mutation 'foo { }'
  mutation 'foo'
end

Mutant::Meta::Example.add :procarg0 do
  source 'foo { |(a)| }'

  singleton_mutations
  mutation 'foo { |(a)| raise }'
  mutation 'foo { |(_a)| }'
  mutation 'foo { }'
  mutation 'foo'
end

Mutant::Meta::Example.add :procarg0 do
  source 'foo { |(a, b)| }'

  singleton_mutations
  mutation 'foo { |(a, b)| raise }'
  # This mutation is a bug--it doesn't make sense to promote the entire arguments to the first mlhs
  # argument. This is meant to show that `a` is unused but that is not what is happening here. We
  # are also missing the underscoring of `_b` .
  mutation 'foo { |_a| }'
  mutation 'foo { }'
  mutation 'foo'
end
