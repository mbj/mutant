RSpec.describe Mutant::Reporter::Trace do
  let(:object) { described_class.new }

  describe '#delay' do
    subject { object.delay }

    it { should eql(0.0) }
  end

  let(:value) { instance_double(Object) }

  %i[report start progress].each do |name|
    describe "##{name}" do
      subject { object.public_send(name, value) }

      it 'logs the value' do
        expect { subject }
          .to change { object.public_send("#{name}_calls") }
          .from([])
          .to([value])
      end
    end
  end
end
