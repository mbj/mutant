# encoding: utf-8

Mutant::Meta::Example.add do
  source '/foo/'

  singleton_mutations
  mutation '//'    # match all
  mutation '/a\A/' # match nothing
end

Mutant::Meta::Example.add do
  source '/#{foo.bar}n/'

  singleton_mutations
  mutation '//' # match all
  mutation '/#{foo}n/'
  mutation '/a\A/'         # match nothing
  mutation '/#{nil.bar}n/'
  mutation '/#{self.bar}n/'
  mutation '/#{nil}n/'
  mutation '/#{self}n/'
end
