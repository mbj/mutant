Mutant::Meta::Example.add do
  source 'defined?(foo)'

  mutation 'defined?(nil)'
  mutation 'true'
  mutation 'false'
end
