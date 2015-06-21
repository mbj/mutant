RSpec.describe Mutant::Expression do
  let(:object) { described_class }

  describe '.try_parse' do
    subject { object.try_parse(input) }

    context 'on nonsense' do
      let(:input) { 'foo bar' }

      it { should be(nil) }
    end

    context 'on a valid expression' do
      let(:input) { 'Foo' }

      it { should eql(Mutant::Expression::Namespace::Exact.new('Foo')) }
    end

    context 'on ambiguous expression' do
      class ExpressionA < Mutant::Expression
        register(/\Atest-syntax\z/)
      end

      class ExpressionB < Mutant::Expression
        register(/^test-syntax$/)
      end

      let(:input) { 'test-syntax' }

      it 'raises an exception' do
        expect { subject }.to raise_error(
          Mutant::Expression::AmbiguousExpressionError,
          'Ambiguous expression: "test-syntax"'
        )
      end
    end
  end

  describe '#prefix?' do
    let(:object) { described_class.parse('Foo*') }

    subject { object.prefix?(other) }

    context 'when object is a prefix of other' do
      let(:other) { described_class.parse('Foo::Bar') }

      it { should be(true) }
    end

    context 'when other is not a prefix of other' do
      let(:other) { described_class.parse('Bar') }

      it { should be(false) }
    end
  end

  describe '#inspect' do
    let(:object) { described_class.parse('Foo') }

    subject { object.inspect }

    it { should eql('<Mutant::Expression: Foo>') }
    it_should_behave_like 'an idempotent method'
  end

  describe '#_dump' do
    let(:object) { described_class.parse('Foo') }
    subject { object._dump(double('Level')) }

    it { should eql('Foo') }
  end

  describe '.parse' do
    subject { object.parse(input) }

    context 'on nonsense' do
      let(:input) { 'foo bar' }

      it 'raises an exception' do
        expect { subject }.to raise_error(
          Mutant::Expression::InvalidExpressionError,
          'Expression: "foo bar" is not valid'
        )
      end
    end

    context 'on a valid expression' do
      let(:input) { 'Foo' }

      it { should eql(Mutant::Expression::Namespace::Exact.new('Foo')) }
    end
  end

  describe '._load' do
    subject { described_class._load('Foo') }

    it { should eql(described_class.parse('Foo')) }
  end
end
