# frozen_string_literal: true

RSpec.describe User do
  def adult?(age)
    User.find(User.create!(age:).id).adult?
  end

  it 'is not an adult below 18' do
    expect(adult?(17)).to be(false)
  end

  it 'is an adult above 18' do
    expect(adult?(21)).to be(true)
  end

  # The covering example is only loaded when WITH_COVERING_SPEC is set, so the
  # verify run can demonstrate both a surviving mutation (without it) and 100%
  # coverage (with it) against a real, persisted record.
  if ENV['WITH_COVERING_SPEC']
    it 'is an adult exactly at 18' do
      expect(adult?(18)).to be(true)
    end
  end

  # Resets the users table (no transactional-fixture config in this helper) and
  # returns the inactive report for the given records.
  def inactive_users(records)
    User.delete_all
    records.each { |record| User.create!(record) }
    User.inactive
  end

  it 'returns archived, deleted regional users' do
    users = inactive_users([
      { age: 30, deleted_at: Time.current, status: 'archived', region: 'EU' },
      { age: 25, deleted_at: Time.current, status: 'active',  region: 'EU' },
    ])
    expect(users).to include(User.find_by(age: 30, status: 'archived'))
    expect(users).not_to include(User.find_by(age: 25, status: 'active'))
  end

  # The covering example is only loaded when WITH_COVERING_SPEC is set, so the
  # verify run can demonstrate both a surviving mutation (the DESC->ASC flip
  # on a single-row report) and 100% coverage (two rows with distinct
  # created_at) without it.
  if ENV['WITH_COVERING_SPEC']
    it 'orders inactive users by created_at descending' do
      old = Time.current
      recent = old + 60
      users = inactive_users([
        { age: 30, deleted_at: old,    status: 'archived', region: 'EU', created_at: old },
        { age: 40, deleted_at: recent, status: 'archived', region: 'EU', created_at: recent },
      ])
      expect(users.map(&:age)).to eq([40, 30])
    end
  end
end
