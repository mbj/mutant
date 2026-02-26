# frozen_string_literal: true

Mutant::Meta::Example.add :casgn do
  source 'A = true'

  mutation 'A__MUTANT__ = true'
  mutation 'A = false'
  mutation 'remove_const :A'
end

Mutant::Meta::Example.add :casgn do
  source 'self::A = true'

  mutation 'self::A__MUTANT__ = true'
  mutation 'self::A = false'
  mutation 'self.remove_const :A'
end

Mutant::Meta::Example.add :casgn do
  source 'A &&= true'

  mutation 'A__MUTANT__ &&= true'
  mutation 'A &&= false'
  mutation 'A ||= true'
end
