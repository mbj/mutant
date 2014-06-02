# encoding: utf-8

Mutant::Meta::Example.add do
  source 'A::B::C'

  mutation 'nil'
  mutation 'B::C'
  mutation 'C'
end
