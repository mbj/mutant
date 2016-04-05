Mutant::Meta::Example.add :kwarg do
  source 'def foo(bar:); end'

  mutation 'def foo; end'
  mutation 'def foo(bar:); raise; end'
  mutation 'remove_method(:foo)'
end
