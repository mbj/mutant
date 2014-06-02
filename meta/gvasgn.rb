# encoding: utf-8

Mutant::Meta::Example.add do
  source '$a = true'

  mutation '$a__mutant__ = true'
  mutation '$a = false'
  mutation '$a = nil'
  mutation 'nil'
end
