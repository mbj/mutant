# frozen_string_literal: true

Mutant::Meta::Example.add :csend do
  source 'a&.b'

  singleton_mutations
  mutation 'a.b'
  mutation 'self&.b'
  mutation 'a'
end

Mutant::Meta::Example.add :csend do
  source 'a&.public_send(:b)'

  singleton_mutations
  mutation ':b'
  mutation 'a.public_send(:b)'
  mutation 'a'
  mutation 'a&.public_send'
  mutation 'a&.public_send(:b__mutant__)'
  mutation 'a&.public_send(nil)'
  mutation 'self&.public_send(:b)'
  mutation 'a&.b'
end
