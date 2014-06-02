# encoding: utf-8

Mutant::Meta::Example.add do
  source 'return'

  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'return foo'

  mutation 'foo'
  mutation 'return nil'
  mutation 'nil'
end
