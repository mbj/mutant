# frozen_string_literal: true

RSpec.describe Mutant::Result::Test::VoidValue do
  describe '.new' do
    it 'returns expected attributes' do
      expect(described_class.instance.to_h).to eql(
        output:  '',
        passed:  false,
        runtime: 0.0
      )
    end
  end
end
