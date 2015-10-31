RSpec.describe Mutant::Env do
  context '#kill' do
    let(:object) do
      described_class.new(
        config:           config,
        actor_env:        Mutant::Actor::Env.new(Thread),
        cache:            Mutant::Cache.new,
        selector:         selector,
        subjects:         [],
        mutations:        [],
        matchable_scopes: [],
        integration:      integration
      )
    end

    let(:integration) { integration_class.new(config) }

    let(:config) do
      Mutant::Config::DEFAULT.with(isolation: isolation, integration: integration_class)
    end

    let(:isolation)         { double('Isolation')                                                     }
    let(:mutation)          { Mutant::Mutation::Evil.new(mutation_subject, Mutant::AST::Nodes::N_NIL) }
    let(:wrapped_node)      { double('Wrapped Node')                                                  }
    let(:context)           { double('Context')                                                       }
    let(:test_a)            { double('Test A')                                                        }
    let(:test_b)            { double('Test B')                                                        }
    let(:tests)             { [test_a, test_b]                                                        }
    let(:selector)          { double('Selector')                                                      }
    let(:integration_class) { Mutant::Integration::Null                                               }

    let(:mutation_subject) do
      double(
        'Subject',
        identification: 'subject',
        context: context,
        source: 'original',
        tests:  tests
      )
    end

    subject { object.kill(mutation) }

    shared_examples_for 'mutation kill' do
      it { should eql(Mutant::Result::Mutation.new(mutation: mutation, test_result: test_result)) }
    end

    before do
      expect(selector).to receive(:call).with(mutation_subject).and_return(tests)
      allow(Time).to receive(:now).and_return(Time.at(0))
    end

    context 'when isolation does not raise error' do
      let(:test_result)  { double('Test Result A', passed: false) }

      before do
        expect(isolation).to receive(:call).and_yield.and_return(test_result)
        expect(mutation_subject).to receive(:prepare).and_return(mutation_subject).ordered
        expect(context).to receive(:root).with(s(:nil)).and_return(wrapped_node).ordered
        expect(Mutant::Loader::Eval).to receive(:call).with(wrapped_node, mutation_subject).and_return(nil).ordered
      end

      include_examples 'mutation kill'
    end

    context 'when isolation does raise error' do
      before do
        expect(isolation).to receive(:call).and_raise(Mutant::Isolation::Error, 'test-error')
      end

      let(:test_result) { Mutant::Result::Test.new(tests: tests, output: 'test-error', passed: false, runtime: 0.0) }

      include_examples 'mutation kill'
    end
  end
end
