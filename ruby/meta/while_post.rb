# frozen_string_literal: true

Mutant::Meta::Example.add :while_post do
  source <<~'RUBY'
    begin
      foo
    end while true
  RUBY

  singleton_mutations

  mutation <<~'RUBY'
    begin
      foo
    end while false
  RUBY

  mutation <<~'RUBY'
    begin
      foo
    end until true
  RUBY

  mutation <<~'RUBY'
    begin
      nil
    end while true
  RUBY

  mutation <<~'RUBY'
    begin
      raise
    end while true
  RUBY
end

Mutant::Meta::Example.add :while_post do
  source <<~'RUBY'
    begin
      foo
      bar
    end while true
  RUBY

  singleton_mutations

  mutation <<~'RUBY'
    begin
      foo
      bar
    end while false
  RUBY

  mutation <<~'RUBY'
    begin
      foo
      bar
    end until true
  RUBY

  mutation <<~'RUBY'
    begin
      nil
      bar
    end while true
  RUBY

  mutation <<~'RUBY'
    begin
      foo
      nil
    end while true
  RUBY

  mutation <<~'RUBY'
    begin
      raise
    end while true
  RUBY
end
