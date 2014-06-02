# encoding: utf-8

Mutant::Meta::Example.add do
  source 'next true'

  mutation 'next false'
  mutation 'next nil'
  mutation 'next'
  mutation 'nil'
  mutation 'break true'
end
