RSpec.describe Mutant::Reporter::Null do
  let(:object) { described_class.new }

  Mutant::Reporter::TYPES.each do |name|
    describe "##{name}" do
      subject { object.public_send(name, double('some input')) }
      it_should_behave_like 'a command method'
    end
  end
end
