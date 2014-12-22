RSpec.describe Mutant::Env do
  let(:object) do
    described_class.new(
      config:           config,
      actor_env:        Mutant::Actor::Env.new(Thread),
      cache:            Mutant::Cache.new,
      subjects:         [],
      mutations:        [],
      matchable_scopes: []
    )
  end

  let(:config) { Mutant::Config::DEFAULT.update(jobs: 1, reporter: Mutant::Reporter::Trace.new) }

  context '#kill_mutation' do
    let(:result)   { double('Result')   }
    let(:mutation) { double('Mutation') }

    subject { object.kill_mutation(mutation) }

    before do
      expect(mutation).to receive(:kill).with(config.isolation, config.integration).and_return(result)
    end

    it 'uses the configured integration and isolation to kill mutation' do
      should eql(Mutant::Result::Mutation.new(mutation: mutation, test_result: result))
    end
  end
end
