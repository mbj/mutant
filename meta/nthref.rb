# encoding: utf-8

Mutant::Meta::Example.add do
  source '$1'

  mutation '$2'
end

Mutant::Meta::Example.add do
  source '$2'

  mutation '$3'
  mutation '$1'
end
