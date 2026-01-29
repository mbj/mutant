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
end

# Standalone rescue with captures (exception class) - no handler promotion
# Tests emit_handler_promotion does NOT promote when there are captures
Mutant::Meta::Example.add :rescue do
  source 'begin; rescue SomeError; bar; end'

  singleton_mutations

  # Mutate handler to nil
  mutation 'begin; rescue SomeError; nil; end'

  # emit_concat promotes handler (no body before rescue means just emit handler)
  # This comes from mutate_rescue_bodies, NOT emit_handler_promotion
  mutation 'begin; bar; end'

  # No emit_handler_promotion because of captures (SomeError is a capture)
end

# Standalone rescue with assignment - no handler promotion
# Tests emit_handler_promotion does NOT promote when there is assignment (=> e)
Mutant::Meta::Example.add :rescue do
  source 'begin; rescue => e; bar; end'

  singleton_mutations

  # Mutate handler to nil
  mutation 'begin; rescue => e; nil; end'

  # No emit_concat because assignment exists (the check in mutate_rescue_bodies)
  # No emit_handler_promotion because of assignment (=> e)
end

# Standalone rescue with multiple clauses (with captures) - no handler promotion
# Tests emit_handler_promotion does NOT promote when multiple rescue clauses
Mutant::Meta::Example.add :rescue do
  source 'begin; rescue ErrorA; bar; rescue ErrorB; baz; end'

  singleton_mutations

  # Mutate first handler
  mutation 'begin; rescue ErrorA; nil; rescue ErrorB; baz; end'

  # Mutate second handler
  mutation 'begin; rescue ErrorA; bar; rescue ErrorB; nil; end'

  # emit_concat for first handler (no assignment)
  mutation 'begin; bar; end'

  # emit_concat for second handler (no assignment)
  mutation 'begin; baz; end'

  # Remove first rescue clause
  mutation 'begin; rescue ErrorB; baz; end'

  # Remove second rescue clause
  mutation 'begin; rescue ErrorA; bar; end'

  # No emit_handler_promotion because multiple clauses exist
end

# Standalone rescue with multiple clauses (no captures, no assignment) - no handler promotion
# This is the key test: it would incorrectly promote if rescue_indices.one? is bypassed
Mutant::Meta::Example.add :rescue do
  source 'begin; rescue; bar; rescue; baz; end'

  singleton_mutations

  # Mutate first handler
  mutation 'begin; rescue; nil; rescue; baz; end'

  # Mutate second handler
  mutation 'begin; rescue; bar; rescue; nil; end'

  # emit_concat for first handler (no assignment)
  mutation 'begin; bar; end'

  # emit_concat for second handler (no assignment)
  mutation 'begin; baz; end'

  # Remove first rescue clause
  mutation 'begin; rescue; baz; end'

  # Remove second rescue clause
  mutation 'begin; rescue; bar; end'

  # No emit_handler_promotion because multiple clauses exist (even without captures)
end

# Standalone rescue with no handler body - no handler promotion
# Tests emit_handler_promotion does NOT promote when resbody.body is nil
Mutant::Meta::Example.add :rescue do
  source 'begin; rescue; end'

  singleton_mutations

  # No handler promotion because handler body is nil
  # No emit_concat because handler body is nil
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
