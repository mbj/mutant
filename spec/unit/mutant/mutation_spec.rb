RSpec.describe Mutant::Mutation do
  class TestMutation < Mutant::Mutation
    SYMBOL = 'test'.freeze
  end

  let(:object)  { TestMutation.new(mutation_subject, Mutant::AST::Nodes::N_NIL) }
  let(:context) { instance_double(Mutant::Context)                              }

  let(:mutation_subject) do
    instance_double(
      Mutant::Subject,
      identification: 'subject',
      context:        context,
      source:         'original'
    )
  end

  let(:test_a) { instance_double(Mutant::Test) }
  let(:test_b) { instance_double(Mutant::Test) }

  describe '#insert' do
    subject { object.insert(kernel) }

    let(:root_node) { s(:foo)                 }
    let(:kernel)    { instance_double(Kernel) }

    before do
      expect(context).to receive(:root)
        .with(object.node)
        .and_return(root_node)

      expect(mutation_subject).to receive(:prepare)
        .ordered
        .and_return(mutation_subject)

      expect(Mutant::Loader).to receive(:call)
        .ordered
        .with(
          binding: TOPLEVEL_BINDING,
          kernel:  kernel,
          node:    root_node,
          subject: mutation_subject
        )
        .and_return(Mutant::Loader)
    end

    it_should_behave_like 'a command method'
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
