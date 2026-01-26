# frozen_string_literal: true

Mutant::Meta::Example.add :if_guard do
  source 'case x; in y if condition; true; end'

  # Mutations of the case_match target (x → nil)
  mutation 'case nil; in y if condition; true; end'

  # Mutations of the guard condition
  mutation 'case x; in y if true; true; end'
  mutation 'case x; in y if false; true; end'
  mutation 'case x; in y if nil; true; end'

  # Mutations of the body (true → false)
  mutation 'case x; in y if condition; false; end'
end

Mutant::Meta::Example.add :unless_guard do
  source 'case x; in y unless condition; true; end'

  # Mutations of the case_match target (x → nil)
  mutation 'case nil; in y unless condition; true; end'

  # Mutations of the guard condition
  mutation 'case x; in y unless true; true; end'
  mutation 'case x; in y unless false; true; end'
  mutation 'case x; in y unless nil; true; end'

  # Mutations of the body (true → false)
  mutation 'case x; in y unless condition; false; end'
end
