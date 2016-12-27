RSpec.describe Mutant::AST::Regexp, '.parse' do
  it 'parses using minor ruby version' do
    expect(described_class.parse(/foo/).to_re).to eql(/foo/)
  end
end
