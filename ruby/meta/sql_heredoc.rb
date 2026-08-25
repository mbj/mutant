# frozen_string_literal: true

# SQL heredoc mutations are driven by a real parser (pg_query), so the
# expected mutation strings are the parser's own deparse output: keywords
# upper-cased, whitespace normalized, the whole query on one line, and no
# trailing newline (the heredoc's final newline is consumed by the parser).

Mutant::Meta::Example.add :str do
  source <<~RUBY
    <<~SQL
      SELECT * FROM users WHERE id = 1 AND active = 1 ORDER BY name ASC
    SQL
  RUBY

  singleton_mutations
  mutation '""'

  mutation '"SELECT * FROM users WHERE id = 1 OR active = 1 ORDER BY name ASC"'
  mutation '"SELECT * FROM users WHERE id = 1 AND active = 1 ORDER BY name DESC"'
end

Mutant::Meta::Example.add :str do
  source <<~RUBY
    <<~SQL
      SELECT * FROM users WHERE name IS NULL AND age IN (1, 2) ORDER BY name DESC
    SQL
  RUBY

  singleton_mutations
  mutation '""'

  mutation '"SELECT * FROM users WHERE name IS NOT NULL AND age IN (1, 2) ORDER BY name DESC"'
  mutation '"SELECT * FROM users WHERE name IS NULL OR age IN (1, 2) ORDER BY name DESC"'
  mutation '"SELECT * FROM users WHERE name IS NULL AND age NOT IN (1, 2) ORDER BY name DESC"'
  mutation '"SELECT * FROM users WHERE name IS NULL AND age IN (1, 2) ORDER BY name ASC"'
end

Mutant::Meta::Example.add :str do
  source <<~RUBY
    <<~SQL
      SELECT * FROM users WHERE EXISTS (SELECT 1 FROM users)
    SQL
  RUBY

  singleton_mutations
  mutation '""'

  mutation '"SELECT * FROM users WHERE NOT EXISTS (SELECT 1 FROM users)"'
end

# A non-SQL heredoc tag is left alone — the body is not parsed as SQL, so
# only the ordinary string-literal mutations fire.
Mutant::Meta::Example.add :str do
  source <<~RUBY
    <<~HTML
      <p>SELECT * FROM users WHERE id = 1 AND active = 1</p>
    HTML
  RUBY

  singleton_mutations
  mutation '""'
end

# A plain double-quoted string is not a heredoc, so no SQL mutations fire.
Mutant::Meta::Example.add :str do
  source '"SELECT * FROM users WHERE id = 1 AND active = 1"'

  singleton_mutations
  mutation '""'
end

# Multi-line heredoc bodies parse to +:dstr+, not +:str+. pg_query's deparser
# rewrites the body to a single line, so the mutated node is a plain +:str+
# (no trailing newline, no per-line children).
Mutant::Meta::Example.add :dstr do
  source <<~RUBY
    <<~SQL
      SELECT * FROM users
      WHERE id = 1 AND active = 1
    SQL
  RUBY

  singleton_mutations
  mutation '""'

  mutation '"SELECT * FROM users WHERE id = 1 OR active = 1"'
end
