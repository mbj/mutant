# frozen_string_literal: true

Mutant::Meta::Example.add :sclass do
  source 'class << self; bar; end'

  mutation 'class << self; nil; end'
end

Mutant::Meta::Example.add :sclass do
  source 'class << self; end'
end
