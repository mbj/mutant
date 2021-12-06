# frozen_string_literal: true

Mutant::Meta::Example.add :send do
  source 'T.must(a > b)'
end

Mutant::Meta::Example.add :send do
  source '::T.must(a > b)'
end
