# encoding: utf-8

Mutant::Meta::Example.add do
  source 'yield true'

  mutation 'yield false'
  mutation 'yield nil'
  mutation 'yield'
  mutation 'nil'
end
