# encoding: utf-8

Mutant::Meta::Example.add do
  source 'true and false'

  mutation 'nil'
  mutation 'true'
  mutation 'false'
  mutation 'true or false'
  mutation '!true and false'
  mutation '!(true and false)'
end
