# encoding: utf-8

Mutant::Meta::Example.add do
  source 'if condition; true; else false; end'

  singleton_mutations

  # mutation of condition
  mutation 'if !condition; true; else false; end'
  mutation 'if nil;        true; else false; end'
  mutation 'if true;       true; else false; end'
  mutation 'if false;      true; else false; end'

  # Deleted else branch
  mutation 'if condition; true end'

  # Promote if branch
  mutation 'true'

  # Promote else branch
  mutation 'false'

  # Deleted if branch resulting in unless rendering
  mutation 'unless condition; false; end'

  # Deleted if branch with promoting else branch to if branch
  mutation 'if condition; false end'

  # mutation of if body
  mutation 'if condition; false; else false; end'
  mutation 'if condition; nil;   else false; end'

  # mutation of else body
  mutation 'if condition; true;  else true;  end'
  mutation 'if condition; true;  else nil;   end'
end

Mutant::Meta::Example.add do
  source 'if condition; true; end'

  singleton_mutations
  mutation 'if !condition; true;  end'
  mutation 'if condition;  false; end'
  mutation 'if condition;  nil;   end'
  mutation 'if true;       true;  end'
  mutation 'if false;      true;  end'
  mutation 'if nil;        true;  end'
  mutation 'true'
end

Mutant::Meta::Example.add do
  source 'unless condition; true; end'

  singleton_mutations
  mutation 'unless !condition; true;  end'
  mutation 'unless nil;        true;  end'
  mutation 'unless true;       true;  end'
  mutation 'unless false;      true;  end'
  mutation 'unless condition;  false; end'
  mutation 'unless condition;  nil;   end'
  mutation 'if     condition;  true;  end'
  mutation 'true'
end
