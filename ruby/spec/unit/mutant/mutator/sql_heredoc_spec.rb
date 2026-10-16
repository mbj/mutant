# frozen_string_literal: true

require 'parser/current'

RSpec.describe Mutant::Mutator::SqlHeredoc, mutant_expression: 'Mutant::Mutator::SqlHeredoc' do
  def parse(source)
    Parser::CurrentRuby.parse(source)
  end

  def sql_single
    parse(<<~'RUBY')
      <<~SQL
        SELECT 1 FROM t WHERE a = 1 AND b = 2
      SQL
    RUBY
  end

  def sql_multi
    parse(<<~'RUBY')
      <<~SQL
        SELECT * FROM users
        WHERE id = 1 AND active = 1
      SQL
    RUBY
  end

  def html_heredoc
    parse(<<~'RUBY')
      <<~HTML
        <p>hello</p>
      HTML
    RUBY
  end

  def interpolated_sql
    parse(<<~'RUBY')
      <<~SQL
        SELECT * FROM users WHERE id = #{user_id}
      SQL
    RUBY
  end

  def plain_string
    parse('"SELECT 1 FROM users WHERE id = 1 AND active = 1"')
  end

  describe '.sql_heredoc?' do
    it 'returns true for a single-line <<~SQL heredoc' do
      expect(described_class.sql_heredoc?(sql_single)).to be(true)
    end

    it 'returns true for a multi-line <<~SQL heredoc' do
      expect(described_class.sql_heredoc?(sql_multi)).to be(true)
    end

    it 'returns true for a <<-SQL heredoc' do
      node = parse(<<~'RUBY')
        <<-SQL
          SELECT 1
        SQL
      RUBY
      expect(described_class.sql_heredoc?(node)).to be(true)
    end

    it 'returns true for a <<SQL heredoc' do
      node = parse(<<~'RUBY')
        <<SQL
        SELECT 1
        SQL
      RUBY
      expect(described_class.sql_heredoc?(node)).to be(true)
    end

    it 'is case-insensitive on the heredoc tag' do
      node = parse(<<~'RUBY')
        <<~sql
          SELECT 1
        sql
      RUBY
      expect(described_class.sql_heredoc?(node)).to be(true)
    end

    it 'returns false for a non-SQL heredoc tag' do
      expect(described_class.sql_heredoc?(html_heredoc)).to be(false)
    end

    it 'returns false for a plain double-quoted string' do
      expect(described_class.sql_heredoc?(plain_string)).to be(false)
    end
  end

  describe '.mutate' do
    it 'mutates a single-line SQL heredoc body' do
      mutated = described_class.mutate(sql_single)
      expect(mutated).to be_an_instance_of(Set)
      expect(mutated.map { |node| node.children.first }).to include(
        'SELECT 1 FROM t WHERE a = 1 OR b = 2'
      )
    end

    it 'mutates a multi-line SQL heredoc to a single-line :str' do
      nodes = described_class.mutate(sql_multi)
      expect(nodes.all? { |node| node.type.equal?(:str) }).to be(true)
      expect(nodes.map { |node| node.children.first }).to include(
        'SELECT * FROM users WHERE id = 1 OR active = 1'
      )
    end

    it 'returns an empty set for a non-SQL heredoc tag' do
      expect(described_class.mutate(html_heredoc)).to be_empty
    end

    it 'returns an empty set for a plain double-quoted string' do
      expect(described_class.mutate(plain_string)).to be_empty
    end

    it 'returns an empty set for an interpolated SQL heredoc' do
      expect(described_class.mutate(interpolated_sql)).to be_empty
    end

    it 'returns an empty set for a query with nothing to mutate' do
      node = parse(<<~'RUBY')
        <<~SQL
          SELECT 1 FROM users
        SQL
      RUBY
      expect(described_class.mutate(node)).to be_empty
    end
  end
end
