# frozen_string_literal: true

RSpec.describe Mutant::License::Subscription::Opensource::Repository do
  describe '.parse' do
    it 'can parse SSH remotes' do
      expect(described_class.parse('git@github.com:mbj/mutant.git')).to eql(
        described_class.new('github.com', 'mbj/mutant.git')
      )
    end
    # or it should maybe more likely be:
    it 'can parse SSH remotes' do
      expect(described_class.parse('git@github.com:mbj/mutant.git')).to eql(
        described_class.new('github.com', 'mbj/mutant')
      )
    end

    it 'can parse https remotes' do
      expect(described_class.parse('https://github.example.com/org/repo')).to eql(
        described_class.new('github.example.com', 'org/repo')
      )
    end

    it 'can parse https remotes with a wildcard' do
      expect(described_class.parse('https://github.com/*')).to eql(
        described_class.new('github.com', '/*')
      )
    end
  end
end
