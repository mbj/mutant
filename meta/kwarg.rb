# frozen_string_literal: true

Mutant::Meta::Example.add :kwarg do
  source 'def foo(bar:); end'

  mutation 'def foo; end'
  mutation 'def foo(bar:); raise; end'
  mutation 'def foo(bar:); super; end'
  mutation 'def foo(_bar:); end'
end

Mutant::Meta::Example.add :if do
  source <<~RUBY
    def foo(bar:)
      return true ? [] : [bar]
    end
  RUBY
end
