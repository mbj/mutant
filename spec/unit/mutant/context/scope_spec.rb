RSpec.describe Mutant::Context::Scope do
  let(:object)      { described_class.new(scope, source_path)               }
  let(:scope)       { instance_double(Class, name: instance_double(String)) }
  let(:source_path) { instance_double(Pathname)                             }

  describe '#identification' do
    subject { object.identification }

    it { should be(scope.name) }
  end
end
