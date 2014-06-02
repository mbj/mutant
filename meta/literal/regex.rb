# encoding: utf-8

Mutant::Meta::Example.add do
  source '/foo/'

  mutation '//'    # match all
  mutation '/a\A/' # match nothing
  mutation 'nil'
end

Mutant::Meta::Example.add do
  source '/#{foo.bar}n/'

  mutation '//' # match all
  mutation '/#{foo}n/'
  mutation '/a\A/'         # match nothing
  mutation '/#{nil.bar}n/'
  mutation '/#{nil}n/'
  mutation 'nil'
end
