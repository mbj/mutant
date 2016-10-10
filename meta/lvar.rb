Mutant::Meta::Example.add :lvar do
  source 'a = nil; a'

  mutation 'a = nil; nil'
  mutation 'a = nil; self'
  mutation 'a = nil'
end
