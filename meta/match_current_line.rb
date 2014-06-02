# encoding: utf-8

Mutant::Meta::Example.add do
  source 'true if /foo/'

  mutation 'false if /foo/'
  mutation 'true if //'
  mutation 'nil if /foo/'
  mutation 'true if true'
  mutation 'true if false'
  mutation 'true if nil'
  mutation 'true if /a\A/'
  mutation 'nil'
end
