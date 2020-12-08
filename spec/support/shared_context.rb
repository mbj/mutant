# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module SharedContext
  # Prepend an anonymous module with the new `with` method
  #
  # Using an anonymous module eliminates warnings where `setup_shared_context`
  # is used and one of the shared methods is immediately redefined.
  def with(name, &block)
    new_definition =
      Module.new do
        define_method(name) do
          super().with(instance_eval(&block))
        end
      end

    prepend(new_definition)
  end

  def it_reports(expected_content)
    it 'writes expected report to output' do
      described_class.call(output, reportable)
      output.rewind
      expect(output.read).to eql(expected_content)
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def setup_shared_context
    let(:mutation_a)      { Mutant::Mutation::Evil.new(subject_a, mutation_a_node)   }
    let(:mutation_a_node) { s(:false)                                                }
    let(:mutation_b)      { Mutant::Mutation::Evil.new(subject_a, mutation_b_node)   }
    let(:mutation_b_node) { s(:nil)                                                  }
    let(:mutations)       { [mutation_a, mutation_b]                                 }
    let(:output)          { StringIO.new                                             }
    let(:subject_a_node)  { s(:true)                                                 }
    let(:test_a)          { instance_double(Mutant::Test, identification: 'test-a')  }
    let(:subjects)        { [subject_a]                                              }

    let(:job_a) do
      Mutant::Parallel::Source::Job.new(
        index:   0,
        payload: mutation_a
      )
    end

    let(:job_b) do
      Mutant::Parallel::Source::Job.new(
        index:   1,
        payload: mutation_b
      )
    end

    let(:env) do
      instance_double(
        Mutant::Env,
        amount_mutations:      mutations.length,
        amount_selected_tests: selections.values.flatten.to_set.length,
        amount_subjects:       subjects.length,
        amount_total_tests:    integration.all_tests.length,
        config:                config,
        integration:           integration,
        mutations:             mutations,
        selected_tests:        [test_a].to_set,
        selections:            selections,
        subjects:              subjects,
        test_subject_ratio:    Rational(1),
        world:                 world
      )
    end

    let(:world) do
      instance_double(
        Mutant::World,
        timer: timer
      )
    end

    let(:timer) do
      instance_double(
        Mutant::Timer,
        now: 1.0
      )
    end

    let(:selections) do
      { subject_a => [test_a] }
    end

    let(:integration) do
      instance_double(
        Mutant::Integration,
        all_tests: [test_a]
      )
    end

    let(:status) do
      Mutant::Parallel::Status.new(
        active_jobs: [].to_set,
        payload:     env_result,
        done:        true
      )
    end

    let(:config) do
      Mutant::Config::DEFAULT.with(
        reporter: Mutant::Reporter::Null.new
      ).expand_defaults
    end

    let(:subject_a_context) do
      Mutant::Context.new(
        Object,
        'suvject-a.rb'
      )
    end

    let(:subject_a) do
      instance_double(
        Mutant::Subject,
        context:        subject_a_context,
        node:           subject_a_node,
        source:         Unparser.unparse(subject_a_node),
        identification: 'subject-a'
      )
    end

    before do
      allow(subject_a).to receive(:mutations).and_return([mutation_a, mutation_b])
    end

    let(:env_result) do
      Mutant::Result::Env.new(
        env:             env,
        runtime:         4.0,
        subject_results: [subject_a_result]
      )
    end

    let(:mutation_a_result) do
      Mutant::Result::Mutation.new(
        mutation:         mutation_a,
        isolation_result: mutation_a_isolation_result,
        runtime:          1.0
      )
    end

    let(:mutation_b_result) do
      Mutant::Result::Mutation.new(
        isolation_result: mutation_b_isolation_result,
        mutation:         mutation_b,
        runtime:          1.0
      )
    end

    let(:mutation_a_coverage_result) do
      Mutant::Result::Coverage.new(
        mutation_result: mutation_a_result,
        criteria_result: mutation_a_criteria_result
      )
    end

    let(:mutation_b_coverage_result) do
      Mutant::Result::Coverage.new(
        mutation_result: mutation_b_result,
        criteria_result: mutation_b_criteria_result
      )
    end

    let(:mutation_a_criteria_result) do
      Mutant::Result::CoverageCriteria.new(
        process_abort: false,
        test_result:   true,
        timeout:       false
      )
    end

    let(:mutation_b_criteria_result) do
      Mutant::Result::CoverageCriteria.new(
        process_abort: false,
        test_result:   true,
        timeout:       false
      )
    end

    let(:mutation_a_isolation_result) do
      Mutant::Isolation::Result.new(
        exception:      nil,
        log:            '',
        process_status: nil,
        timeout:        nil,
        value:          mutation_a_test_result
      )
    end

    let(:mutation_a_test_result) do
      Mutant::Result::Test.new(
        tests:   [test_a],
        passed:  false,
        runtime: 1.0
      )
    end

    let(:mutation_b_test_result) do
      Mutant::Result::Test.new(
        tests:   [test_a],
        passed:  false,
        runtime: 1.0
      )
    end

    let(:mutation_b_isolation_result) do
      Mutant::Isolation::Result.new(
        exception:      nil,
        log:            '',
        process_status: nil,
        timeout:        nil,
        value:          mutation_b_test_result
      )
    end

    let(:subject_a_result) do
      Mutant::Result::Subject.new(
        subject:          subject_a,
        tests:            [test_a],
        coverage_results: [mutation_a_coverage_result, mutation_b_coverage_result]
      )
    end
  end
end # SharedContext
