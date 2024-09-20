# frozen_string_literal: true

Mutant::Meta::Example.add :kwarg do
  source 'def foo(bar:); end'

  mutation 'def foo(bar:); raise; end'
  mutation 'def foo(bar:); super; end'
end
