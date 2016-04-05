Mutant::Meta::Example.add :kwoptarg do
  source 'def foo(bar: baz); end'

  mutation 'def foo; end'
  mutation 'def foo(bar: baz); raise; end'
  mutation 'remove_method(:foo)'
  mutation 'def foo(bar: nil); end'
  mutation 'def foo(bar: self); end'
end
