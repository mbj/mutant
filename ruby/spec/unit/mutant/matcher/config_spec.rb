# frozen_string_literal: true

RSpec.describe Mutant::Matcher::Config do
  describe '#merge' do
    def apply
      original.merge(other)
    end

    let(:proc_a) { instance_double(Proc, :a) }
    let(:proc_b) { instance_double(Proc, :b) }

    let(:diff_a) { instance_double(Mutant::Repository::Diff, :a) }
    let(:diff_b) { instance_double(Mutant::Repository::Diff, :b) }

    let(:original) do
      described_class.new(
        ignore:            [parse_expression('Ignore#a')],
        start_expressions: [parse_expression('Start#a')],
        subjects:          [parse_expression('Match#a')],
        diffs:             [diff_a]
      )
    end

    let(:other) do
      described_class.new(
        ignore:            [parse_expression('Ignore#b')],
        start_expressions: [parse_expression('Start#b')],
        subjects:          other_subjects,
        diffs:             [diff_b]
      )
    end

    shared_examples '#merge' do
      it 'returns expected value' do
        expect(apply).to eql(
          described_class.new(
            ignore:            [parse_expression('Ignore#a'), parse_expression('Ignore#b')],
            start_expressions: [parse_expression('Start#a'), parse_expression('Start#b')],
            subjects:          expected_subjects,
            diffs:             [diff_a, diff_b]
          )
        )
      end
    end

    context 'when other has subjects' do
      let(:expected_subjects) { other.subjects }
      let(:other_subjects)    { [parse_expression('Subject#b')] }

      include_examples '#merge'
    end

    context 'when other has no subjects' do
      let(:expected_subjects) { original.subjects }
      let(:other_subjects)    { []                }

      include_examples '#merge'
    end
  end

  describe '#inspect' do
    subject { object.inspect }

    context 'on default config' do
      let(:object) { described_class::DEFAULT }

      it { should eql('#<Mutant::Matcher::Config empty>') }
    end

    context 'with one expression' do
      let(:object) { described_class::DEFAULT.add(:subjects, parse_expression('Foo')) }
      it { should eql('#<Mutant::Matcher::Config subjects: [Foo]>') }
    end

    context 'with many expressions' do
      let(:object) do
        described_class::DEFAULT
          .add(:subjects, parse_expression('Foo'))
          .add(:subjects, parse_expression('Bar'))
      end

      it { should eql('#<Mutant::Matcher::Config subjects: [Foo,Bar]>') }
    end

    context 'with match and ignore expression' do
      let(:object) do
        described_class::DEFAULT
          .add(:subjects, parse_expression('Foo'))
          .add(:ignore,   parse_expression('Bar'))
      end

      it { should eql('#<Mutant::Matcher::Config ignore: [Bar] subjects: [Foo]>') }
    end
  end
end
