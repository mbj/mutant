# frozen_string_literal: true

RSpec.describe Mutant::Mutator::Sql, mutant_expression: 'Mutant::Mutator::Sql' do
  def apply(sql)
    described_class.mutate(sql).to_a.sort
  end

  describe '.mutate' do
    it 'returns a Set for both success and parse-failure' do
      expect(described_class.mutate('SELECT 1 FROM t WHERE a = 1 AND b = 2'))
        .to be_an_instance_of(Set)
      expect(described_class.mutate('this is not sql'))
        .to be_an_instance_of(Set)
    end

    context 'a boolean expression' do
      it 'flips AND to OR' do
        expect(apply('SELECT 1 FROM t WHERE a = 1 AND b = 2'))
          .to eql(['SELECT 1 FROM t WHERE a = 1 OR b = 2'])
      end

      it 'flips OR to AND' do
        expect(apply('SELECT 1 FROM t WHERE a = 1 OR b = 2'))
          .to eql(['SELECT 1 FROM t WHERE a = 1 AND b = 2'])
      end

      it 'flips every arm of a single AND of three predicates' do
        expect(apply('SELECT 1 FROM t WHERE a = 1 AND b = 2 AND c = 3'))
          .to eql(['SELECT 1 FROM t WHERE a = 1 OR b = 2 OR c = 3'])
      end
    end

    context 'a NULL test' do
      it 'flips IS NULL to IS NOT NULL' do
        expect(apply('SELECT 1 FROM t WHERE a IS NULL'))
          .to eql(['SELECT 1 FROM t WHERE a IS NOT NULL'])
      end

      it 'flips IS NOT NULL to IS NULL' do
        expect(apply('SELECT 1 FROM t WHERE a IS NOT NULL'))
          .to eql(['SELECT 1 FROM t WHERE a IS NULL'])
      end
    end

    context 'an IN test' do
      it 'flips IN to NOT IN' do
        expect(apply('SELECT 1 FROM t WHERE a IN (1, 2)'))
          .to eql(['SELECT 1 FROM t WHERE a NOT IN (1, 2)'])
      end

      it 'flips NOT IN to IN' do
        expect(apply('SELECT 1 FROM t WHERE a NOT IN (1, 2)'))
          .to eql(['SELECT 1 FROM t WHERE a IN (1, 2)'])
      end
    end

    context 'an ORDER BY clause' do
      it 'flips ASC to DESC' do
        expect(apply('SELECT 1 FROM t ORDER BY a ASC'))
          .to eql(['SELECT 1 FROM t ORDER BY a DESC'])
      end

      it 'flips DESC to ASC' do
        expect(apply('SELECT 1 FROM t ORDER BY a DESC'))
          .to eql(['SELECT 1 FROM t ORDER BY a ASC'])
      end

      it 'does not flip an implicit (default) ordering' do
        expect(apply('SELECT 1 FROM t ORDER BY a')).to eql([])
      end
    end

    context 'an EXISTS subquery' do
      it 'wraps a bare EXISTS in NOT' do
        expect(apply('SELECT 1 FROM t WHERE EXISTS (SELECT 1 FROM u)'))
          .to eql(['SELECT 1 FROM t WHERE NOT EXISTS (SELECT 1 FROM u)'])
      end

      it 'unwraps a NOT EXISTS back to EXISTS' do
        expect(apply('SELECT 1 FROM t WHERE NOT EXISTS (SELECT 1 FROM u)'))
          .to eql(['SELECT 1 FROM t WHERE EXISTS (SELECT 1 FROM u)'])
      end

      it 'wraps an EXISTS that is an arm of an AND' do
        expect(apply('SELECT 1 FROM t WHERE a = 1 AND EXISTS (SELECT 1 FROM u)'))
          .to eql([
            'SELECT 1 FROM t WHERE a = 1 AND NOT EXISTS (SELECT 1 FROM u)',
            'SELECT 1 FROM t WHERE a = 1 OR EXISTS (SELECT 1 FROM u)'
          ])
      end

      it 'unwraps a NOT EXISTS that is an arm of an AND' do
        expect(apply('SELECT 1 FROM t WHERE a = 1 AND NOT EXISTS (SELECT 1 FROM u)'))
          .to eql([
            'SELECT 1 FROM t WHERE a = 1 AND EXISTS (SELECT 1 FROM u)',
            'SELECT 1 FROM t WHERE a = 1 OR NOT EXISTS (SELECT 1 FROM u)'
          ])
      end

      it 'only unwraps a NOT EXISTS, never produces NOT NOT EXISTS' do
        expect(apply('SELECT 1 FROM t WHERE NOT EXISTS (SELECT 1 FROM u)'))
          .not_to include(a_string_matching('NOT NOT EXISTS'))
      end

      it 'does not wrap a non-EXISTS sublink' do
        expect(apply('SELECT 1 FROM t WHERE a IN (SELECT b FROM u)')).to eql([])
      end

      it 'does not unwrap a NOT that is not a NOT EXISTS' do
        expect(apply('SELECT 1 FROM t WHERE NOT (a = 1)')).to eql([])
      end

      it 'does not unwrap an AND whose first arm is an EXISTS' do
        expect(apply('SELECT 1 FROM t WHERE EXISTS (SELECT 1 FROM u) AND a = 1'))
          .to eql([
            'SELECT 1 FROM t WHERE EXISTS (SELECT 1 FROM u) OR a = 1',
            'SELECT 1 FROM t WHERE NOT EXISTS (SELECT 1 FROM u) AND a = 1'
          ])
      end

      it 'does not unwrap a NOT over a non-EXISTS sublink' do
        expect(apply('SELECT 1 FROM t WHERE NOT (a IN (SELECT b FROM u))')).to eql([])
      end
    end

    context 'a query with several flippable operators' do
      let(:sql) do
        'SELECT * FROM users WHERE name IS NULL AND age IN (1, 2) ORDER BY name DESC'
      end

      it 'emits one mutation per flip' do
        expect(apply(sql)).to eql([
          'SELECT * FROM users WHERE name IS NOT NULL AND age IN (1, 2) ORDER BY name DESC',
          'SELECT * FROM users WHERE name IS NULL AND age IN (1, 2) ORDER BY name ASC',
          'SELECT * FROM users WHERE name IS NULL AND age NOT IN (1, 2) ORDER BY name DESC',
          'SELECT * FROM users WHERE name IS NULL OR age IN (1, 2) ORDER BY name DESC'
        ])
      end
    end

    context 'edge cases a regex would get wrong' do
      it 'does not flip operator keywords inside a string literal' do
        expect(apply("SELECT 1 FROM t WHERE note = 'a OR b' AND active = 1"))
          .to eql(['SELECT 1 FROM t WHERE note = \'a OR b\' OR active = 1'])
      end

      it 'does not flip an operator that is a substring of an identifier' do
        expect(apply('SELECT orders FROM t WHERE orders = 1 AND active = 1'))
          .to eql(['SELECT orders FROM t WHERE orders = 1 OR active = 1'])
      end
    end

    context 'SQL that cannot be parsed' do
      it 'returns no mutations rather than raising' do
        expect(apply('this is not sql')).to eql([])
      end

      it 'returns no mutations for a non-SQL heredoc-shaped body' do
        expect(apply('<p>SELECT * FROM t WHERE a = 1 AND b = 2</p>')).to eql([])
      end
    end

    context 'a query with nothing to mutate' do
      it 'returns no mutations' do
        expect(apply('SELECT 1 FROM t')).to eql([])
      end
    end
  end
end
