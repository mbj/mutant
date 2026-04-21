# frozen_string_literal: true

Mutant::Meta::Example.add :forward_args do
  source 'def foo(...); bar(...); end'

  mutation 'def foo(...); raise; end'
  mutation 'def foo(...); super; end'
  mutation 'def foo(...); end'
  mutation 'def foo(...); nil; end'
  mutation 'def foo(...); bar; end'
end
