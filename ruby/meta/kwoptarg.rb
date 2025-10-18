# frozen_string_literal: true

Mutant::Meta::Example.add :kwarg do
  source 'def foo(bar: baz); end'

  mutation 'def foo(bar: baz); raise; end'
  mutation 'def foo(bar: baz); super; end'
  mutation 'def foo(bar: nil); end'
  mutation 'def foo(bar:); end'
end
