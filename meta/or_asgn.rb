# encoding: utf-8

Mutant::Meta::Example.add do
  source 'a ||= 1'

  singleton_mutations
  mutation 'a__mutant__ ||= 1'
  mutation 'a ||= nil'
  mutation 'a ||= self'
  mutation 'a ||= 0'
  mutation 'a ||= -1'
  mutation 'a ||= 2'
end

Mutant::Meta::Example.add do
  source '@a ||= 1'

  singleton_mutations
  mutation '@a ||= nil'
  mutation '@a ||= self'
  mutation '@a ||= 0'
  mutation '@a ||= -1'
  mutation '@a ||= 2'
end
