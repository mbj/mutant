RSpec.describe Mutant::Mutation do

  class TestMutation < Mutant::Mutation
    SYMBOL = 'test'.freeze
  end

  let(:object)  { TestMutation.new(mutation_subject, Mutant::AST::Nodes::N_NIL) }
  let(:context) { double('Context')                                             }

  let(:mutation_subject) do
    double(
      'Subject',
      identification: 'subject',
      context: context,
      source: 'original',
      tests:  tests
    )
  end

  let(:test_a) { double('Test A') }
  let(:test_b) { double('Test B') }
  let(:tests)  { [test_a, test_b] }

  describe '#kill' do
    let(:isolation)    { Mutant::Isolation::None                                                 }
    let(:integration)  { double('Integration')                                                   }
    let(:object)       { Mutant::Mutation::Evil.new(mutation_subject, Mutant::AST::Nodes::N_NIL) }
    let(:wrapped_node) { double('Wrapped Node')                                                  }

    subject { object.kill(isolation, integration) }

    before do
      allow(Time).to receive(:now).and_return(Time.at(0))
    end

    context 'when isolation does not raise error' do
      let(:test_result)  { double('Test Result A', passed: false)                                  }

      before do
        expect(mutation_subject).to receive(:public?).and_return(true).ordered
        expect(mutation_subject).to receive(:prepare).and_return(mutation_subject).ordered
        expect(context).to receive(:root).with(s(:nil)).and_return(wrapped_node).ordered
        expect(Mutant::Loader::Eval).to receive(:call).with(wrapped_node, mutation_subject).and_return(nil).ordered
        expect(integration).to receive(:call).with(tests).and_return(test_result).ordered
        expect(test_result).to receive(:update).with(tests: tests).and_return(test_result).ordered
      end

      it { should eql(test_result) }
    end

    context 'when isolation does raise error' do
      before do
        expect(isolation).to receive(:call).and_raise(Mutant::Isolation::Error, 'test-error')
      end

      it { should eql(Mutant::Result::Test.new(tests: tests, output: 'test-error', passed: false, runtime: 0.0)) }
    end
  end

  describe '#code' do
    subject { object.code }

    it { should eql('8771a') }

    it_should_behave_like 'an idempotent method'
  end

  describe '#original_source' do
    subject { object.original_source }

    it { should eql('original') }

    it_should_behave_like 'an idempotent method'
  end

  describe '#source' do
    subject { object.source }

    it { should eql('nil') }

    it_should_behave_like 'an idempotent method'
  end

  describe '#identification' do

    subject { object.identification }

    it { should eql('test:subject:8771a') }

    it_should_behave_like 'an idempotent method'
  end
end
