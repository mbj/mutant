# encoding: utf-8

Mutant::Meta::Example.add do
  source 'a, b = c, d'

  mutation 'nil'
end
