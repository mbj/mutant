RSpec.describe Mutant::Subject do
  let(:class_under_test) do
    Class.new(described_class) do
      def expression
        Mutant::Expression.parse('Test')
      end
    end
  end

  let(:object) { class_under_test.new(config, context, node) }

  let(:config) { Mutant::Config::DEFAULT }

  let(:node) do
    double('Node', location: location)
  end

  let(:location) do
    double('Location', expression: expression)
  end

  let(:expression) do
    double('Expression', line: 'source_line')
  end

  let(:context) do
    double(
      'Context',
      source_path: 'source_path',
      source_line: 'source_line'
    )
  end

  describe '#identification' do
    subject { object.identification }

    it { should eql('Test:source_path:source_line') }
  end

  describe '#prepare' do
    subject { object.prepare }

    it_should_behave_like 'a command method'
  end

  describe '#node' do
    subject { object.node }

    it { should be(node) }

    it_should_behave_like 'an idempotent method'
  end

  describe '#mutations' do
    subject { object.mutations }

    before do
      expect(Mutant::Mutator).to receive(:each).with(node).and_yield(mutation_a).and_yield(mutation_b)
    end

    let(:mutation_a) { double('Mutation A') }
    let(:mutation_b) { double('Mutation B') }

    it 'generates neutral and evil mutations' do
      should eql([
        Mutant::Mutation::Neutral.new(object, node),
        Mutant::Mutation::Evil.new(object, mutation_a),
        Mutant::Mutation::Evil.new(object, mutation_b)
      ])
    end
  end
end
