# encoding: utf-8

Mutant::Meta::Example.add do
  source 'foo(*bar)'

  mutation 'foo'
  mutation 'foo(nil)'
  mutation 'foo(bar)'
  mutation 'foo(*nil)'
  mutation 'nil'
end
