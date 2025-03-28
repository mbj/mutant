# frozen_string_literal: true

Mutant::Meta::Example.add :if do
  source 'if condition; true; else false; end'

  singleton_mutations

  # mutation of condition
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

  # mutation of else body
  mutation 'if condition; true;  else true;  end'
end

Mutant::Meta::Example.add :if do
  source 'if condition; true; end'

  singleton_mutations
  mutation 'if condition;  false; end'
  mutation 'if true;       true;  end'
  mutation 'if false;      true;  end'
  mutation 'if nil;        true;  end'
  mutation 'true'
end

Mutant::Meta::Example.add :if do
  source 'unless condition; true; end'

  singleton_mutations
  mutation 'unless nil;        true;  end'
  mutation 'unless true;       true;  end'
  mutation 'unless false;      true;  end'
  mutation 'unless condition;  false; end'
  mutation 'if     condition;  true;  end'
  mutation 'true'
end

Mutant::Meta::Example.add :if do
  source 'true if /foo/'

  singleton_mutations
  mutation 'false if /foo/'
  mutation 'true if //'
  mutation 'true if true'
  mutation 'true if false'
  mutation 'true if nil'
  mutation 'true if /nomatch\A/'
  mutation 'true'
end

Mutant::Meta::Example.add :if do
  source <<~RUBY
    return true ? true : false
  RUBY

  singleton_mutations
  mutation 'return false'
  mutation 'return true'
  mutation 'return false ? true : false'
  mutation 'return true ? false : false'
  mutation 'return true ? true : true'
  mutation 'return nil'
  mutation 'if true; true; else; false; end'
end
