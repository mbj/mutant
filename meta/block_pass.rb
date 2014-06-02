# encoding: utf-8

Mutant::Meta::Example.add do
  source 'foo(&bar)'

  mutation 'foo'
  mutation 'nil'
end
