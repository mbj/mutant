# frozen_string_literal: true

Mutant::Meta::Example.add :regexp, :regexp_latin_property do
  source('/p{Latin}/')

  singleton_mutations
  regexp_mutations
end
