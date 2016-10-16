RSpec.describe Mutant::Reporter::Sequence do
  let(:object)     { described_class.new([reporter_a, reporter_b]) }
  let(:value)      { instance_double(Object)                       }
  let(:reporter_a) { instance_double(Mutant::Reporter, delay: 1.0) }
  let(:reporter_b) { instance_double(Mutant::Reporter, delay: 2.0) }

  %i[report progress warn start].each do |name|
    describe "##{name}" do
      subject { object.public_send(name, value) }

      before do
        [reporter_a, reporter_b].each do |receiver|
          expect(receiver).to receive(name)
            .ordered
            .with(value)
            .and_return(receiver)
        end
      end

      it_should_behave_like 'a command method'
    end
  end

  describe '#delay' do
    it 'returns the lowest value' do
      expect(object.delay).to eql(1.0)
    end
  end
end
