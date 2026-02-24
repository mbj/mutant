# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Mutant::Meta::Example.add :case_match, :in_pattern do
  source <<~RUBY
    case value
    in left then
      true
    in right then
      true
    else
      false
    end
  RUBY

  mutation <<~RUBY
    case nil
    in left then
      true
    in right then
      true
    else
      false
    end
  RUBY

  mutation <<~RUBY
    case value
    in left then
      false
    in right then
      true
    else
      false
    end
  RUBY

  mutation <<~RUBY
    case value
    in left then
      true
    else
      false
    end
  RUBY

  mutation <<~RUBY
    case value
    in left then
      true
    in right then
      false
    else
      false
    end
  RUBY

  mutation <<~RUBY
    case value
    in left then
      true
    in right then
      true
    else
      true
    end
  RUBY

  mutation <<~RUBY
    case value
    in left then
      true
    in right then
      true
    end
  RUBY

  mutation <<~RUBY
    case value
    in right then
      true
    else
      false
    end
  RUBY
end
# rubocop:enable Metrics/BlockLength
