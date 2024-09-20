# frozen_string_literal: true

Mutant::Meta::Example.add :or do
  source 'true or false'

  singleton_mutations
  mutation 'true'
  mutation 'false'
  mutation 'false or false'
  mutation 'true or true'
end

Mutant::Meta::Example.add :or do
  source 'a = true or false'

  mutation 'a = true'
  mutation 'a = false or false'
  mutation 'a = true or true'
end

Mutant::Meta::Example.add :or do
  source 'foo(1..) or bar'

  singleton_mutations
  mutation 'foo(1..)'
  mutation 'bar'
  mutation 'nil || bar'
  mutation 'foo(nil) || bar'
  mutation 'foo(2..) || bar'
  mutation 'foo(1..) || nil'
  mutation 'foo(0..) || bar'
  mutation 'foo(nil..) || bar'
  mutation 'foo || bar'
end

Mutant::Meta::Example.add :or do
  source 'foo(1..2) or bar'

  singleton_mutations
  mutation 'foo(1...2) or bar'
  mutation 'foo(1..2)'
  mutation '1..2 or bar'
  mutation 'bar'
  mutation 'nil || bar'
  mutation 'foo(nil) || bar'
  mutation 'foo(2..2) || bar'
  mutation 'foo(1..2) || nil'
  mutation 'foo(0..2) || bar'
  mutation 'foo(nil..2) || bar'
  mutation 'foo(1..nil) || bar'
  mutation 'foo(1..3) || bar'
  mutation 'foo(1..1) || bar'
  mutation 'foo(1..0) || bar'
  mutation 'foo || bar'
end

Mutant::Meta::Example.add :or do
  source 'foo(1...) or bar'

  singleton_mutations
  mutation 'foo(1...)'
  mutation 'bar'
  mutation 'nil || bar'
  mutation 'foo(nil) || bar'
  mutation 'foo(2...) || bar'
  mutation 'foo(1...) || nil'
  mutation 'foo(0...) || bar'
  mutation 'foo(nil...) || bar'
  mutation 'foo || bar'
end
