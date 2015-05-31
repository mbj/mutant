RSpec.describe Mutant::Reporter::Trace do
  let(:object) { described_class.new }

  describe '#delay' do
    subject { object.delay }

    it { should eql(0.0) }
  end

  let(:reportable) { double('Reportable') }

  %i[report start progress].each do |name|
    describe "##{name}" do
      subject { object.public_send(name, reportable) }

      it 'logs the reportable' do
        expect { subject }.to change { object.public_send("#{name}_calls") }.from([]).to([reportable])
      end
    end
  end
end
