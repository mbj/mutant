# frozen_string_literal: true

Mutant::Meta::Example.add :until_post do
  source <<~'RUBY'
    begin
      foo
    end until true
  RUBY

  singleton_mutations

  mutation <<~'RUBY'
    begin
      foo
    end until false
  RUBY

  mutation <<~'RUBY'
    begin
      foo
    end while true
  RUBY

  mutation <<~'RUBY'
    begin
      nil
    end until true
  RUBY

  mutation <<~'RUBY'
    begin
      raise
    end until true
  RUBY
end
