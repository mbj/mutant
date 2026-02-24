# frozen_string_literal: true

# Inline rescue modifier - promotes handler body when no captures/assignment
Mutant::Meta::Example.add :rescue do
  source 'foo rescue bar'

  singleton_mutations

  # Mutate body to nil
  mutation 'nil rescue bar'

  # Promote body (remove rescue)
  mutation 'foo'

  # Mutate handler to nil
  mutation 'foo rescue nil'

  # Concat body and handler
  mutation 'foo; bar'

  # Promote handler (use fallback directly)
  mutation 'bar'
end

Mutant::Meta::Example.add :rescue do
  source 'begin; rescue ExceptionA, ExceptionB => error; true; end'

  singleton_mutations
  mutation 'begin; rescue ExceptionA, ExceptionB => error; false; end'

end

Mutant::Meta::Example.add :rescue do
  source 'begin; rescue SomeException => error; true; end'

  singleton_mutations
  mutation 'begin; rescue SomeException => error; false; end'
end

Mutant::Meta::Example.add :rescue do
  source 'begin; rescue => error; true end'

  singleton_mutations
  mutation 'begin; rescue => error; false; end'
end

Mutant::Meta::Example.add :rescue do
  source 'begin; rescue; true end'

  singleton_mutations
  mutation 'begin; rescue; false; end'
  mutation 'begin; true end'
end

Mutant::Meta::Example.add :rescue do
  source 'begin; true; end'

  singleton_mutations
  mutation 'begin; false; end'
end

Mutant::Meta::Example.add :rescue do
  source 'def a; foo; rescue; bar; else; baz; end'

  # Mutate all bodies
  mutation 'def a; nil;  rescue; bar; else; baz; end'
  mutation 'def a; foo; rescue; nil;  else; baz; end'
  mutation 'def a; foo; rescue; bar; else; nil; end'

  # Promote and concat rescue resbody bodies
  mutation 'def a; foo; bar; end'

  # Promote and concat else body
  mutation 'def a; foo; baz; end'

  # Promote rescue body
  mutation 'def a; foo; end'

  # Empty body
  mutation 'def a; end'

  # Failing body
  mutation 'def a; raise; end'

  # Superclass implementation
  mutation 'def a; super; end'
end

Mutant::Meta::Example.add :rescue do
  source 'begin; rescue; ensure; true; end'

  singleton_mutations
  mutation 'begin; rescue; ensure; false; end'
  mutation 'begin; rescue; end'
end

# Multiple rescue clauses with assignment - test individual clause removal
Mutant::Meta::Example.add :rescue do
  source 'def a; foo; rescue ErrorA => e; bar; rescue ErrorB => e; baz; end'

  # Mutate try body
  mutation 'def a; nil; rescue ErrorA => e; bar; rescue ErrorB => e; baz; end'

  # Mutate first rescue body
  mutation 'def a; foo; rescue ErrorA => e; nil; rescue ErrorB => e; baz; end'

  # Mutate second rescue body
  mutation 'def a; foo; rescue ErrorA => e; bar; rescue ErrorB => e; nil; end'

  # Promote try body (remove all rescues)
  mutation 'def a; foo; end'

  # Empty body
  mutation 'def a; end'

  # Failing body
  mutation 'def a; raise; end'

  # Superclass implementation
  mutation 'def a; super; end'

  # Remove first rescue clause (keep second)
  mutation 'def a; foo; rescue ErrorB => e; baz; end'

  # Remove second rescue clause (keep first)
  mutation 'def a; foo; rescue ErrorA => e; bar; end'
end
