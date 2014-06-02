# encoding: utf-8

Mutant::Meta::Example.add do
  source 'begin; true; end'

  mutation 'begin; false; end'
  mutation 'begin; nil; end'
  mutation 'nil'
end
