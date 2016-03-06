Mutant::Meta::Example.add :casgn do
  source 'A = true'

  mutation 'A__MUTANT__ = true'
  mutation 'A = false'
  mutation 'A = nil'
  mutation 'remove_const :A'
end

Mutant::Meta::Example.add :casgn do
  source 'self::A = true'

  mutation 'self::A__MUTANT__ = true'
  mutation 'self::A = false'
  mutation 'self::A = nil'
  mutation 'self.remove_const :A'
end

Mutant::Meta::Example.add :casgn do
  source 'A &&= true'

  singleton_mutations
  mutation 'A__MUTANT__ &&= true'
  mutation 'A &&= false'
  mutation 'A &&= nil'
end
