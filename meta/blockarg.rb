# encoding: utf-8

Mutant::Meta::Example.add do
  source 'foo { |&bar| }'

  mutation 'foo { |&bar| raise }'
  mutation 'foo {}'
  mutation 'foo'
  mutation 'nil'
end
