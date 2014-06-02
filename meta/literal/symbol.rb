# encoding: utf-8

Mutant::Meta::Example.add do
  source ':foo'

  mutation 'nil'
  mutation ':foo__mutant__'
end
