RSpec.describe Mutant::Env do
  context '#kill' do
    let(:object) do
      described_class.new(
        config:           config,
        actor_env:        Mutant::Actor::Env.new(Thread),
        parser:           Mutant::Parser.new,
        selector:         selector,
        subjects:         [],
        mutations:        [],
        matchable_scopes: [],
        integration:      integration
      )
    end

    let(:integration) { instance_double(Mutant::Integration) }

    let(:config) do
      Mutant::Config::DEFAULT.with(isolation: isolation, integration: integration_class)
    end

    let(:isolation)         { instance_double(Mutant::Isolation::Fork.singleton_class)                }
    let(:mutation)          { Mutant::Mutation::Evil.new(mutation_subject, Mutant::AST::Nodes::N_NIL) }
    let(:wrapped_node)      { instance_double(Parser::AST::Node)                                      }
    let(:context)           { instance_double(Mutant::Context)                                        }
    let(:test_a)            { instance_double(Mutant::Test)                                           }
    let(:test_b)            { instance_double(Mutant::Test)                                           }
    let(:tests)             { [test_a, test_b]                                                        }
    let(:selector)          { instance_double(Mutant::Selector)                                       }
    let(:integration_class) { Mutant::Integration::Null                                               }

    let(:mutation_subject) do
      instance_double(
        Mutant::Subject,
        identification: 'subject',
        context: context,
        source: 'original'
      )
    end

    subject { object.kill(mutation) }

    shared_examples_for 'mutation kill' do
      it { should eql(Mutant::Result::Mutation.new(mutation: mutation, test_result: test_result)) }
    end

    before do
      expect(selector).to receive(:call)
        .with(mutation_subject)
        .and_return(tests)

      allow(Time).to receive_messages(now: Time.at(0))
    end

    context 'when isolation does not raise error' do
      let(:test_result)  { instance_double(Mutant::Result::Test, passed: false) }

      before do
        expect(isolation).to receive(:call)
          .ordered
          .and_yield

        expect(mutation_subject).to receive(:prepare)
          .ordered
          .and_return(mutation_subject)

        expect(context).to receive(:root)
          .with(s(:nil))
          .and_return(wrapped_node)

        expect(Mutant::Loader::Eval).to receive(:call)
          .ordered
          .with(wrapped_node, mutation_subject)
          .and_return(Mutant::Loader::Eval)

        expect(integration).to receive(:call)
          .ordered
          .with(tests)
          .and_return(test_result)
      end

      include_examples 'mutation kill'
    end

    context 'when isolation does raise error' do
      before do
        expect(isolation).to receive(:call)
          .and_raise(Mutant::Isolation::Error, 'test-error')
      end

      let(:test_result) do
        Mutant::Result::Test.new(
          tests:   tests,
          output:  'test-error',
          passed:  false,
          runtime: 0.0
        )
      end

      include_examples 'mutation kill'
    end
  end
end
