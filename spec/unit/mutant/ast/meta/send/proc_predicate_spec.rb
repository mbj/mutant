RSpec.describe Mutant::AST::Meta::Send, '#proc?' do
  subject { described_class.new(node).proc? }

  shared_context 'proc send' do |source|
    let(:node) { Parser::CurrentRuby.parse(source).children.first }
  end

  shared_examples 'proc definition' do |*args|
    include_context 'proc send', *args

    it { should be(true) }
  end

  shared_examples 'not a proc definition' do |*args|
    include_context 'proc send', *args

    it { should be_falsey }
  end

  it_behaves_like 'proc definition', 'proc { }'
  it_behaves_like 'proc definition', 'Proc.new { }'
  it_behaves_like 'not a proc definition', 'new { }'
  it_behaves_like 'not a proc definition', 'foo.proc { }'
  it_behaves_like 'not a proc definition', 'Proc.blah { }'
  it_behaves_like 'not a proc definition', 'Proc().new { }'
  it_behaves_like 'not a proc definition', 'Foo.new { }'
  it_behaves_like 'not a proc definition', 'blah { }'
end
