# frozen_string_literal: true

Mutant::Meta::Example.add :str do
  source <<~RUBY
    <<~SQL
      SELECT * FROM users WHERE id = 1 AND active = 1 ORDER BY name ASC
    SQL
  RUBY

  singleton_mutations
  mutation '""'

  mutation '"SELECT * FROM users WHERE id = 1 OR active = 1 ORDER BY name ASC\n"'
  mutation '"SELECT * FROM users WHERE id = 1 AND active = 1 ORDER BY name DESC\n"'
end

Mutant::Meta::Example.add :str do
  source <<~RUBY
    <<~SQL
      SELECT * FROM users WHERE name IS NULL AND age IN (1, 2) ORDER BY name DESC
    SQL
  RUBY

  singleton_mutations
  mutation '""'

  mutation '"SELECT * FROM users WHERE name IS NOT NULL AND age IN (1, 2) ORDER BY name DESC\n"'
  mutation '"SELECT * FROM users WHERE name IS NULL OR age IN (1, 2) ORDER BY name DESC\n"'
  mutation '"SELECT * FROM users WHERE name IS NULL AND age NOT IN (1, 2) ORDER BY name DESC\n"'
  mutation '"SELECT * FROM users WHERE name IS NULL AND age IN (1, 2) ORDER BY name ASC\n"'
end

Mutant::Meta::Example.add :str do
  source <<~RUBY
    <<~SQL
      SELECT * FROM users WHERE EXISTS (SELECT 1 FROM users)
    SQL
  RUBY

  singleton_mutations
  mutation '""'

  mutation '"SELECT * FROM users WHERE NOT EXISTS (SELECT 1 FROM users)\n"'
end

Mutant::Meta::Example.add :str do
  source <<~RUBY
    <<~HTML
      <p>SELECT * FROM users WHERE id = 1 AND active = 1</p>
    HTML
  RUBY

  singleton_mutations
  mutation '""'
end

Mutant::Meta::Example.add :str do
  source '"SELECT * FROM users WHERE id = 1 AND active = 1"'

  singleton_mutations
  mutation '""'
end
