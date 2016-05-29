RSpec.describe Mutant::AST::Regexp, '.supported?' do
  subject { described_class.supported?(expression) }

  let(:expression) { described_class.parse(regexp) }
  let(:regexp)     { /foo/                         }

  it { should be(true) }

  context 'conditional regular expressions' do
    let(:regexp) { /((?(1)(foo)(bar)))/ }

    it { should be(false) }
  end
end
