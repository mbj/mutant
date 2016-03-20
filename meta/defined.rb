Mutant::Meta::Example.add :defined? do
  source 'defined?(foo)'

  singleton_mutations
  mutation 'defined?(nil)'
  mutation 'true'
end
