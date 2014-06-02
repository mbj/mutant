# encoding: utf-8

Mutant::Meta::Example.add do
  source 'true or false'

  mutation 'nil'
  mutation 'true'
  mutation 'false'
  mutation 'true and false'
  mutation '!true or false'
  mutation '!(true or false)'
end
