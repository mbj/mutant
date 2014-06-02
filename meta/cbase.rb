# encoding: utf-8

Mutant::Meta::Example.add do
  source '::A'

  mutation 'nil'
  mutation 'A'
end
