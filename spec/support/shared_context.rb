# rubocop:disable ModuleLength
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

  def messages(&block)
    let(:message_sequence) do
      FakeActor::MessageSequence.new.tap do |sequence|
        sequence.instance_eval(&block)
      end
    end
  end

  def it_reports(expected_content)
    it 'writes expected report to output' do
      described_class.call(output, reportable)
      output.rewind
      expect(output.read).to eql(strip_indent(expected_content))
    end
  end

  # rubocop:disable MethodLength
  # rubocop:disable AbcSize
  def setup_shared_context
    let(:env)              { instance_double(Mutant::Env, config: config, subjects: [subject_a], mutations: mutations) }
    let(:job_a)            { Mutant::Parallel::Job.new(index: 0, payload: mutation_a)                                  }
    let(:job_b)            { Mutant::Parallel::Job.new(index: 1, payload: mutation_b)                                  }
    let(:test_a)           { instance_double(Mutant::Test, identification: 'test-a')                                   }
    let(:output)           { StringIO.new                                                                              }
    let(:mutations)        { [mutation_a, mutation_b]                                                                  }
    let(:mutation_a_node)  { s(:false)                                                                                 }
    let(:mutation_b_node)  { s(:nil)                                                                                   }
    let(:mutation_b)       { Mutant::Mutation::Evil.new(subject_a, mutation_b_node)                                    }
    let(:mutation_a)       { Mutant::Mutation::Evil.new(subject_a, mutation_a_node)                                    }
    let(:subject_a_node)   { s(:true)                                                                                  }

    let(:status) do
      Mutant::Parallel::Status.new(
        active_jobs: [].to_set,
        payload:     env_result,
        done:        true
      )
    end

    let(:config) do
      Mutant::Config::DEFAULT.with(
        jobs:     1,
        reporter: Mutant::Reporter::Null.new
      )
    end

    let(:subject_a) do
      instance_double(
        Mutant::Subject,
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
        mutation:    mutation_a,
        test_result: mutation_a_test_result
      )
    end

    let(:mutation_b_result) do
      Mutant::Result::Mutation.new(
        mutation:    mutation_a,
        test_result: mutation_b_test_result
      )
    end

    let(:mutation_a_test_result) do
      Mutant::Result::Test.new(
        tests:   [test_a],
        passed:  false,
        runtime: 1.0,
        output:  'mutation a test result output'
      )
    end

    let(:mutation_b_test_result) do
      Mutant::Result::Test.new(
        tests:   [test_a],
        passed:  false,
        runtime: 1.0,
        output:  'mutation b test result output'
      )
    end

    let(:subject_a_result) do
      Mutant::Result::Subject.new(
        subject:          subject_a,
        tests:            [test_a],
        mutation_results: [mutation_a_result, mutation_b_result]
      )
    end
  end
end # SharedContext
