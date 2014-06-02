# encoding: utf-8

Mutant::Meta::Example.add do
  source 'defined?(foo)'

  mutation 'defined?(nil)'
end
