RSpec.describe Mutant::Repository::SubjectFilter do
  context '#call' do
    subject { object.call(mutant_subject) }

    let(:object)       { described_class.new(diff) }
    let(:diff)         { double('Diff')            }
    let(:return_value) { double('Return Value')    }

    let(:mutant_subject) do
      double(
        'Subject',
        source_path:  double('source path'),
        source_lines: double('source lines')
      )
    end

    before do
      expect(diff).to receive(:touches?).with(
        mutant_subject.source_path,
        mutant_subject.source_lines
      ).and_return(return_value)
    end

    it 'connects return value to repository diff API' do
      expect(subject).to be(return_value)
    end
  end
end
