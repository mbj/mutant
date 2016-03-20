Mutant::Meta::Example.add :restarg do
  source 'foo(*bar)'

  singleton_mutations
  mutation 'foo'
  mutation 'foo(nil)'
  mutation 'foo(self)'
  mutation 'foo(*self)'
  mutation 'foo(bar)'
  mutation 'foo(*nil)'
end
