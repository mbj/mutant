# frozen_string_literal: true

RSpec.describe Mutant::Repository::SubjectFilter do
  context '#call' do
    def apply
      subject.call(mutant_subject)
    end

    subject do
      described_class.new(
        diff:     diff,
        revision: 'revision',
        world:    fake_world
      )
    end

    let(:diff) { instance_double(Mutant::Repository::Diff) }

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
      ).and_return(touches?)
    end

    context 'when subject lines are not touched' do
      let(:touches?) { false }

      it 'returns false' do
        expect(apply).to be(false)
      end
    end
  end
end
