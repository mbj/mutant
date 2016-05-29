RSpec.describe Mutant::AST::Regexp, '.parse' do
  before { stub_const('RUBY_VERSION', '2.3.9') }

  it 'parses using minor ruby version' do
    expect(described_class.parse(/foo/).to_re).to eql(/foo/)
  end
end
