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
      described_class.call(output:, object: reportable)
      output.rewind
      expect(output.read).to eql(expected_content)
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def setup_shared_context
    let(:mutation_a_node) { s(:false)                                                }
    let(:mutation_b_node) { s(:nil)                                                  }
    let(:mutations)       { [mutation_a, mutation_b]                                 }
    let(:output)          { StringIO.new                                             }
    let(:subject_a_node)  { s(:true)                                                 }
    let(:test_a)          { instance_double(Mutant::Test, identification: 'test-a')  }
    let(:test_b)          { instance_double(Mutant::Test, identification: 'test-b')  }
    let(:subjects)        { [subject_a]                                              }

    let(:mutation_a) do
      Mutant::Mutation::Evil.from_node(subject: subject_a, node: mutation_a_node).from_right
    end

    let(:mutation_b) do
      Mutant::Mutation::Evil.from_node(subject: subject_a, node: mutation_b_node).from_right
    end

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
        amount_mutations:       mutations.length,
        amount_selected_tests:  selections.values.flatten.to_set.length,
        amount_subjects:        subjects.length,
        amount_all_tests:       integration.all_tests.length,
        amount_available_tests: integration.available_tests.length,
        config:,
        integration:,
        mutations:,
        selected_tests:         [test_a].to_set,
        selections:,
        subjects:,
        test_subject_ratio:     Rational(1),
        world:
      )
    end

    let(:world) do
      instance_double(
        Mutant::World,
        timer:
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
        all_tests:       [test_a, test_b],
        available_tests: [test_a]
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
        mutation: Mutant::Mutation::Config::DEFAULT,
        reporter: Mutant::Reporter::Null.new
      )
    end

    let(:scope) do
      Mutant::Scope.new(
        expression: Mutant::Expression::Namespace::Exact.new(scope_name: 'Object'),
        raw:        Object
      )
    end

    let(:subject_a_context) do
      Mutant::Context.new(
        constant_scope: Mutant::Context::ConstantScope::None.new,
        scope:,
        source_path:    'subject-a.rb'
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
        env:,
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

    let(:mutation_a_index_result) do
      Mutant::Result::MutationIndex.new(
        isolation_result: mutation_a_isolation_result,
        mutation_index:   0,
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

    let(:mutation_b_index_result) do
      Mutant::Result::MutationIndex.new(
        isolation_result: mutation_b_isolation_result,
        mutation_index:   1,
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
        job_index: 0,
        output:    '',
        passed:    false,
        runtime:   1.0
      )
    end

    let(:mutation_b_test_result) do
      Mutant::Result::Test.new(
        job_index: 1,
        output:    '',
        passed:    false,
        runtime:   1.0
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
