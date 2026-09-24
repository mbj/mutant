# frozen_string_literal: true

class User < ApplicationRecord
  def adult?
    age >= 18
  end

  # The "inactive users" report: archived, deleted, regional users ordered
  # newest-first. A find_by_sql heredoc so ORDER BY lives inside the SQL body
  # and the SQL keyword mutations (AND/OR, IN/NOT IN, IS NULL/IS NOT NULL,
  # ASC/DESC) are exercised against a real, persisted record.
  def self.inactive
    find_by_sql(<<~SQL)
      SELECT * FROM users
      WHERE deleted_at IS NOT NULL
        AND status = 'archived'
        AND region IN ('EU', 'US')
      ORDER BY created_at DESC
    SQL
  end
end
