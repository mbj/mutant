# encoding: utf-8

Mutant::Meta::Example.add do
  source 'super'

  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'super()'

  mutation 'super'
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source 'super(foo, bar)'

  mutation 'super'
  mutation 'super()'
  mutation 'super(foo)'
  mutation 'super(bar)'
  mutation 'super(foo, nil)'
  mutation 'super(nil, bar)'
  mutation 'nil'
end
