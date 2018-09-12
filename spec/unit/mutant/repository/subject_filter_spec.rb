# frozen_string_literal: true

RSpec.describe Mutant::Repository::SubjectFilter do
  context '#call' do
    subject { object.call(mutant_subject) }

    let(:object) { described_class.new(diff)                 }
    let(:diff)   { instance_double(Mutant::Repository::Diff) }
    let(:value)  { instance_double(Object, 'value')          }

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
      ).and_return(value)
    end

    it 'connects return value to repository diff API' do
      expect(subject).to be(value)
    end
  end
end
