# frozen_string_literal: true

Mutant::Meta::Example.add :begin do
  source 'true; false'

  mutation 'true; true'
  mutation 'false; false'
  mutation 'true'
  mutation 'false'
end

Mutant::Meta::Example.add :begin do
  source 'a = false; a'

  mutation 'a = false'
  mutation 'a = true; a'
  mutation 'a = false; nil'
end

Mutant::Meta::Example.add :begin do
  source 'true; true; true'

  mutation 'true; true; false'
  mutation 'true; false; true'
  mutation 'false; true; true'
  mutation 'true; true'
end

Mutant::Meta::Example.add :begin do
  source 'a = true; a'

  mutation 'a = false; a'
  mutation 'a = true; nil'
  mutation 'a = true'
end

Mutant::Meta::Example.add :begin do
  source '(true)'

  mutation '(false)'
end

Mutant::Meta::Example.add :begin do
  source '(true); true'

  mutation '(false); true'
  mutation '(true)'
  mutation '(true); false'
  mutation 'true'
end

Mutant::Meta::Example.add :begin do
  source 'a, b = true, true; a'

  mutation 'a, b = []; a'
  mutation 'a, b = [true]; a'
  mutation 'a, b = false, true; a'
  mutation 'a, b = nil; a'
  mutation 'a, b = true, false; a'
  mutation 'a, b = true, true'
  mutation 'a, b = true, true; nil'
end

Mutant::Meta::Example.add :begin do
  source 'foo.bar, foo.bar = true, true'

  mutation 'foo.bar, foo.bar = []'
  mutation 'foo.bar, foo.bar = [true]'
  mutation 'foo.bar, foo.bar = false, true'
  mutation 'foo.bar, foo.bar = nil'
  mutation 'foo.bar, foo.bar = true, false'
end

Mutant::Meta::Example.add :begin do
  source 'foo; 1'

  mutation '1'
  mutation 'foo'
  mutation 'foo; 0'
  mutation 'foo; 2'
  mutation 'foo; nil'
  mutation 'nil; 1'
end

Mutant::Meta::Example.add :begin do
  source '((a = 1)); a'

  mutation '((a = 1))'
  mutation '((a = 1)); nil'
  mutation '((a = 2)); a'
  mutation '((a = 0)); a'
  mutation '((a = nil)); a'
end

Mutant::Meta::Example.add :begin do
  source '((a; b))'

  mutation '((a; nil))'
  mutation '((nil; b))'
  mutation '(a)'
  mutation '(b)'
end

Mutant::Meta::Example.add :begin do
  source 'a; b'

  mutation 'a'
  mutation 'b'
  mutation 'nil; b'
  mutation 'a; nil'
end

Mutant::Meta::Example.add :begin do
  source <<~'RUBY'
    def foo
      a = nil
      a
    end
    a
  RUBY

  mutation <<~'RUBY'
    def foo
      a = nil
      a
    end
  RUBY

  mutation <<~'RUBY'
    def foo
      a = nil
      a
    end
    nil
  RUBY

  mutation <<~'RUBY'
    def foo
      a = nil
    end
    a
  RUBY

  mutation <<~'RUBY'
    def foo
      a = nil
      nil
    end
    a
  RUBY

  mutation <<~'RUBY'
    def foo
    end
    a
  RUBY

  mutation <<~'RUBY'
    def foo
      super
    end
    a
  RUBY

  mutation <<~'RUBY'
    def foo
      raise
    end
    a
  RUBY

  mutation 'a'
end
