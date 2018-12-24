# frozen_string_literal: true

RSpec.describe Mutant::AST::Regexp, '.parse' do
  def apply(input)
    described_class.parse(input)
  end

  context 'on regexp regexp_parser does accept' do
    it 'parses using minor ruby version' do
      expect(apply(/foo/).to_re).to eql(/foo/)
    end
  end

  context 'on regexp regexp_parser does not accept' do
    it 'returns nil' do
      expect(apply(/u{/)).to be(nil)
    end
  end
end
