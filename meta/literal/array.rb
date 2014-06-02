# encoding: utf-8

Mutant::Meta::Example.add do
  source '[true]'

  mutation 'nil'
  mutation 'true'
  mutation '[false]'
  mutation '[nil]'
  mutation '[]'
end

Mutant::Meta::Example.add do
  source '[true, false]'

  mutation 'nil'

  # Mutation of each element in array
  mutation '[nil, false]'
  mutation '[false, false]'
  mutation '[true, nil]'
  mutation '[true, true]'

  # Remove each element of array once
  mutation '[true]'
  mutation '[false]'

  # Empty array
  mutation '[]'
end
