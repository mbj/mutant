RSpec.describe Mutant::Matcher::Config do
  describe '#inspect' do
    subject { object.inspect }

    context 'on default config' do
      let(:object) { described_class::DEFAULT }

      it { should eql('#<Mutant::Matcher::Config empty>') }
    end

    context 'with one expression' do
      let(:object) { described_class::DEFAULT.add(:match_expressions, parse_expression('Foo')) }
      it { should eql('#<Mutant::Matcher::Config match_expressions: [Foo]>') }
    end

    context 'with many expressions' do
      let(:object) do
        described_class::DEFAULT
          .add(:match_expressions, parse_expression('Foo'))
          .add(:match_expressions, parse_expression('Bar'))
      end

      it { should eql('#<Mutant::Matcher::Config match_expressions: [Foo,Bar]>') }
    end

    context 'with match and ignore expression' do
      let(:object) do
        described_class::DEFAULT
          .add(:match_expressions,  parse_expression('Foo'))
          .add(:ignore_expressions, parse_expression('Bar'))
      end

      it { should eql('#<Mutant::Matcher::Config ignore_expressions: [Bar] match_expressions: [Foo]>') }
    end

    context 'with subject filter' do
      let(:object) do
        described_class::DEFAULT
          .add(:subject_filters, 'foo')
      end

      it { should eql('#<Mutant::Matcher::Config subject_filters: ["foo"]>') }
    end
  end
end
