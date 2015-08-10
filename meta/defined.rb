Mutant::Meta::Example.add do
  source 'defined?(foo)'

  singleton_mutations
  mutation 'defined?(nil)'
  mutation 'true'
end
