# frozen_string_literal: true

def verses(first_verse, last_verse)
  first_verse.downto(last_verse).map { verse(_1) }.join("\n")
end
