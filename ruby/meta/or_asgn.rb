# frozen_string_literal: true

Mutant::Meta::Example.add :or_asgn do
  source 'a ||= 1'

  singleton_mutations
  mutation 'a ||= nil'
  mutation 'a ||= 0'
  mutation 'a ||= 2'
  mutation 'a &&= 1'

  # overflow boundary probe (int8 zone)
  mutation 'a ||= 167'
end

Mutant::Meta::Example.add :or_asgn do
  source '@a ||= 1'

  singleton_mutations
  mutation '@a ||= nil'
  mutation '@a ||= 0'
  mutation '@a ||= 2'
  mutation '@a &&= 1'

  # overflow boundary probe (int8 zone)
  mutation '@a ||= 167'
end

Mutant::Meta::Example.add :or_asgn do
  source 'Foo ||= nil'

  singleton_mutations
  mutation 'Foo &&= nil'
end

Mutant::Meta::Example.add :or_asgn do
  source '@a ||= self.bar'

  singleton_mutations
  mutation '@a ||= nil'
  mutation '@a ||= self'
  mutation '@a ||= bar'
  mutation '@a &&= self.bar'
end

Mutant::Meta::Example.add :or_asgn do
  source 'foo[:bar] ||= 1'

  singleton_mutations
  mutation 'foo[:bar] ||= nil'
  mutation 'foo[:bar] ||= 0'
  mutation 'foo[:bar] ||= 2'
  mutation 'foo[:bar] &&= 1'

  # overflow boundary probe (int8 zone)
  mutation 'foo[:bar] ||= 167'
end
