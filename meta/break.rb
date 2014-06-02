# encoding: utf-8

Mutant::Meta::Example.add do
  source 'break true'

  mutation 'break false'
  mutation 'break nil'
  mutation 'break'
  mutation 'nil'
  mutation 'next true'
end
