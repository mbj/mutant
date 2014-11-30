RSpec.describe Mutant::Test do
  let(:object) { described_class.new(integration, expression) }

  let(:integration)    { double('Integration', name: 'test-integration') }
  let(:expression)     { double('Expression', syntax: 'test-syntax')     }
  let(:report)         { double('Report')                                }
  let(:updated_report) { double('Updated Report')                        }

  describe '#identification' do
    subject { object.identification }

    it { should eql('test-integration:test-syntax') }
  end

  describe '#kill' do
    let(:isolation) { Mutant::Isolation::None }
    let(:mutation)  { double('Mutation')      }

    subject { object.kill(isolation, mutation) }

    before do
      expect(mutation).to receive(:insert)
    end

    context 'when isolation does not raise' do
      before do
        expect(report).to receive(:update).with(test: object).and_return(updated_report)
      end

      it 'runs test via integration' do
        expect(integration).to receive(:run).with(object).and_return(report)
        expect(subject).to be(updated_report)
      end
    end

    context 'when isolation does raise' do
      before do
        allow(Time).to receive(:now).and_return(Time.at(0))
      end

      it 'runs test via integration' do
        expect(integration).to receive(:run).with(object).and_raise(Mutant::Isolation::Error, 'fake message')
        expect(subject).to eql(Mutant::Result::Test.new(
          test:     object,
          mutation: mutation,
          output:   'fake message',
          passed:   false,
          runtime:  0.0
        ))
      end
    end
  end
end
