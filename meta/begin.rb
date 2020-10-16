# frozen_string_literal: true

Mutant::Meta::Example.add :begin do

  source 'true; false'
  # Mutation of each statement in block
  mutation 'true; true'
  mutation 'false; false'

  # Delete each statement
  mutation 'true'
  mutation 'false'
end

Mutant::Meta::Example.add :begin do
  source '(true)'

  mutation '(false)'
end
