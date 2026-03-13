# frozen_string_literal: true

RSpec.describe Mutant::Reporter::JSON do
  setup_shared_context

  let(:object) { described_class.build(output) }

  def contents
    output.rewind
    output.read
  end

  def parsed_output
    JSON.parse(contents)
  end

  describe '.build' do
    subject { described_class.build(output) }

    it { is_expected.to eql(described_class.new(output:)) }
  end

  describe '#delay' do
    subject { object.delay }

    it { is_expected.to eql(Float::INFINITY) }
  end

  %i[warn start test_start progress test_progress].each do |name|
    describe "##{name}" do
      subject { object.public_send(name, instance_double(Object)) }

      it_behaves_like 'a command method'

      it 'does not write to output' do
        subject
        expect(contents).to eql('')
      end
    end
  end

  describe '#report' do
    subject { object.report(env_result) }

    let(:expected_output) do
      {
        'schema_version'  => '1.0.0',
        'mutant_version'  => Mutant::VERSION,
        'report_type'     => 'mutation_analysis',
        'summary'         => {
          'runtime'  => 4.0,
          'killtime' => 2.0,
          'coverage' => '1/1',
          'mutations' => 2,
          'results'   => 2,
          'kills'     => 2,
          'alive'     => 0,
          'timeouts'  => 0,
          'success'   => true
        },
        'environment'     => {
          'subjects'           => 1,
          'all_tests'          => 2,
          'available_tests'    => 1,
          'selected_tests'     => 1,
          'test_subject_ratio' => '1/1'
        },
        'subject_results' => [
          {
            'subject'          => 'subject-a',
            'source_path'      => 'subject-a.rb',
            'source_line'      => 1,
            'source_lines'     => { 'begin' => 1, 'end' => 1 },
            'tests'            => ['test-a'],
            'coverage'         => '1/1',
            'mutations_killed' => 2,
            'mutations_alive'  => 0,
            'timeouts'         => 0,
            'killtime'         => 2.0,
            'runtime'          => 2.0,
            'alive_mutations'  => []
          }
        ]
      }
    end

    it_behaves_like 'a command method'

    it 'emits expected JSON' do
      subject
      expect(parsed_output).to eql(expected_output)
    end

    context 'with alive mutations' do
      with(:mutation_a_criteria_result) { { test_result: false } }

      it 'emits expected JSON with alive details and success false' do
        subject
        result = parsed_output

        expect(result.fetch('summary').fetch('success')).to eql(false)
        expect(result.fetch('summary').fetch('coverage')).to eql('1/2')
        expect(result.fetch('subject_results').first.fetch('coverage')).to eql('1/2')

        alive = result.fetch('subject_results').first.fetch('alive_mutations')

        expect(alive.length).to eql(1)
        expect(alive.first).to eql(
          'identification' => mutation_a.identification,
          'mutation_type'  => 'evil',
          'code'           => mutation_a.code,
          'diff'           => mutation_a.diff.diff,
          'criteria'       => {
            'test_result'   => false,
            'timeout'       => false,
            'process_abort' => false
          },
          'runtime'        => 1.0,
          'killtime'       => 1.0
        )
      end
    end
  end

  describe '#test_report' do
    let(:test_env_result) do
      Mutant::Result::TestEnv.new(
        env:,
        runtime:      1.0,
        test_results: [failed_test]
      )
    end

    let(:failed_test) do
      Mutant::Result::Test.new(
        job_index: 0,
        output:    'test failure output',
        passed:    false,
        runtime:   0.5
      )
    end

    subject { object.test_report(test_env_result) }

    let(:expected_output) do
      {
        'schema_version'     => '1.0.0',
        'mutant_version'     => Mutant::VERSION,
        'report_type'        => 'test_verification',
        'summary'            => {
          'runtime'       => 1.0,
          'testtime'      => 0.5,
          'tests'         => 2,
          'test_results'  => 1,
          'tests_failed'  => 1,
          'tests_success' => 0,
          'success'       => false
        },
        'failed_test_results' => [
          {
            'passed'  => false,
            'runtime' => 0.5,
            'output'  => 'test failure output'
          }
        ]
      }
    end

    it_behaves_like 'a command method'

    it 'emits expected JSON' do
      subject
      expect(parsed_output).to eql(expected_output)
    end

    context 'with all tests passing' do
      let(:test_env_result) do
        Mutant::Result::TestEnv.new(
          env:,
          runtime:      1.0,
          test_results: [passing_test]
        )
      end

      let(:passing_test) do
        Mutant::Result::Test.new(
          job_index: 0,
          output:    '',
          passed:    true,
          runtime:   0.5
        )
      end

      it 'emits success true' do
        subject
        expect(parsed_output.fetch('summary').fetch('success')).to eql(true)
      end
    end
  end
end
