# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI do
  setup_shared_context

  let(:object) { described_class.new(output, format) }
  let(:tty?)   { false                               }

  let(:format) do
    described_class::Format::Progressive.new(tty?)
  end

  def contents
    output.rewind
    output.read
  end

  def self.it_reports(expected_content)
    it 'writes expected report to output' do
      expect(subject).to be(object)
      expect(contents).to eql(expected_content)
    end
  end

  describe '.build' do
    subject { described_class.build(output) }

    context 'when output is a tty' do
      let(:tty?)   { true                            }
      let(:output) { instance_double(IO, tty?: true) }

      it { should eql(described_class.new(output, format)) }
    end

    context 'when output is not a tty' do
      context 'and does not respond to #tty?' do
        let(:output) { nil }

        it { should eql(described_class.new(output, format)) }
      end

      context 'and does respond to #tty?' do
        it { should eql(described_class.new(output, format)) }
      end
    end
  end

  describe '#warn' do
    subject { object.warn(message) }

    let(:message) { 'message' }

    it_reports("message\n")
  end

  describe '#delay' do
    subject { object.delay }

    it { should eql(1.0) }
  end

  describe '#start' do
    subject { object.start(env) }

    it_reports(<<~REPORT)
      Mutant environment:
      Matcher:         #<Mutant::Matcher::Config empty>
      Integration:     null
      Jobs:            1
      Includes:        []
      Requires:        []
      Subjects:        1
      Total-Tests:     1
      Selected-Tests:  1
      Tests/Subject:   1.00 avg
      Mutations:       2
    REPORT
  end

  describe '#report' do
    subject { object.report(env_result) }

    it_reports(<<~REPORT)
      Mutant environment:
      Matcher:         #<Mutant::Matcher::Config empty>
      Integration:     null
      Jobs:            1
      Includes:        []
      Requires:        []
      Subjects:        1
      Total-Tests:     1
      Selected-Tests:  1
      Tests/Subject:   1.00 avg
      Mutations:       2
      Results:         2
      Kills:           2
      Alive:           0
      Runtime:         4.00s
      Killtime:        2.00s
      Overhead:        100.00%
      Mutations/s:     0.50
      Coverage:        100.00%
    REPORT
  end

  describe '#progress' do
    subject { object.progress(status) }

    context 'with empty scheduler' do
      with(:env_result) { { subject_results: [] } }

      let(:tty?) { true }

      # rubocop:disable Layout/LineLength
      # rubocop:disable Style/StringConcatenation
      it_reports Unparser::Color::GREEN.format('progress: 00/02 alive: 0 runtime: 4.00s killtime: 0.00s mutations/s: 0.00') + "\n"
      # rubocop:enable Style/StringConcatenation
      # rubocop:enable Layout/LineLength
    end

    context 'with last mutation present' do
      with(:env_result) { { subject_results: [subject_a_result] } }

      context 'when mutation is successful' do
        it_reports "progress: 02/02 alive: 0 runtime: 4.00s killtime: 2.00s mutations/s: 0.50\n"
      end

      context 'when mutation is NOT successful' do
        with(:mutation_a_test_result) { { passed: true } }

        it_reports "progress: 02/02 alive: 1 runtime: 4.00s killtime: 2.00s mutations/s: 0.50\n"
      end
    end
  end
end
