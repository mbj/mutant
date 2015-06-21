RSpec.describe Mutant::Context::Scope do
  let(:object)      { described_class.new(scope, source_path) }
  let(:scope)       { double('scope', name: double('name'))   }
  let(:source_path) { double('source path')                   }

  describe '#identification' do
    subject { object.identification }

    it { should be(scope.name) }
  end
end
