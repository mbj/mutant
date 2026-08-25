# frozen_string_literal: true

Mutant::Meta::Example.add :str do
  source <<~RUBY
    <<~SQL
      SELECT * FROM users WHERE id = 1 AND active = 1 ORDER BY name ASC
    SQL
  RUBY

  singleton_mutations
  mutation '""'

  # SQL keyword mutations
  mutation '"SELECT * FROM users WHERE id = 1 OR active = 1 ORDER BY name ASC\n"'
  mutation '"SELECT * FROM users WHERE id = 1 AND active = 1 ORDER BY name DESC\n"'
end
