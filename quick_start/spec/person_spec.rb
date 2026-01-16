# frozen_string_literal: true

require_relative '../lib/person'

RSpec.describe Person do
  describe '#adult?' do
    it 'returns true for age 19' do
      expect(Person.new(age: 19).adult?).to be(true)
    end

    it 'returns false for age 17' do
      expect(Person.new(age: 17).adult?).to be(false)
    end

    # This test is conditionally included to support CI verification of the quick_start example.
    #
    # The quick_start example intentionally has incomplete test coverage to demonstrate
    # how mutant detects shallow tests. Without this boundary test, mutant finds surviving
    # mutations when >= is changed to > (the tests don't cover age == 18).
    #
    # CI runs mutant twice:
    # 1. Without WITH_COVERING_SPEC: expects mutations to survive (demonstrating the problem)
    # 2. With WITH_COVERING_SPEC: expects 100% coverage (demonstrating the fix)
    #
    # This validates both scenarios work correctly.
    if ENV['WITH_COVERING_SPEC']
      it 'returns true for age 18' do
        expect(Person.new(age: 18).adult?).to be(true)
      end
    end
  end
end
