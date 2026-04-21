# frozen_string_literal: true

Mutant::Meta::Example.add :forward_arg do
  source 'def foo(a, ...); bar(a, ...); end'

  mutation 'def foo(a, ...); raise; end'
  mutation 'def foo(a, ...); super; end'
  mutation 'def foo(a, ...); end'
  mutation 'def foo(a, ...); nil; end'
  mutation 'def foo(a, ...); bar; end'
  mutation 'def foo(a, ...); bar(nil, ...); end'
  mutation 'def foo(a, ...); bar(...); end'
  mutation 'def foo(a, ...); bar(a); end'
end
