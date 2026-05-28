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
end
