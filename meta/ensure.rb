# encoding: utf-8

Mutant::Meta::Example.add do
  source 'begin; rescue; ensure; true; end'

  mutation 'begin; rescue; ensure; false; end'
  mutation 'begin; rescue; ensure; nil; end'
  mutation 'nil'
end
