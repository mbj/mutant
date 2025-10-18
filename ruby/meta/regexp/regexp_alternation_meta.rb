# frozen_string_literal: true

Mutant::Meta::Example.add :regexp_alternation_meta do
  source '/\A(foo|bar|baz)\z/'

  singleton_mutations
  regexp_mutations

  mutation '/\A(foo|bar)\z/'
  mutation '/\A(foo|baz)\z/'
  mutation '/\A(bar|baz)\z/'
  mutation '/\A(?:foo|bar|baz)\z/'
end
