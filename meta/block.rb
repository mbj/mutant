# encoding: utf-8

Mutant::Meta::Example.add do
  source 'foo() { a; b }'

  mutation 'foo { a }'
  mutation 'foo { b }'
  mutation 'foo {}'
  mutation 'foo { raise }'
  mutation 'foo { a; nil }'
  mutation 'foo { nil; b }'
  mutation 'foo'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'foo { |a, b| }'

  mutation 'foo'
  mutation 'foo { |a, b| raise }'
  mutation 'foo { |a, b__mutant__| }'
  mutation 'foo { |a__mutant__, b| }'
  mutation 'foo { |a| }'
  mutation 'foo { |b| }'
  mutation 'foo { || }'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'foo { |(a, b), c| }'

  mutation 'nil'
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
  source 'foo { |(a)| }'

  mutation 'foo { || }'
  mutation 'foo { |a| }'
  mutation 'foo { |(a)| raise }'
  mutation 'foo { |(a__mutant__)| }'
  mutation 'foo'
  mutation 'nil'
end
