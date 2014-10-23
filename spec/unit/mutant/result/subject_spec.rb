RSpec.describe Mutant::Result::Subject do
  let(:object) do
    described_class.new(
      subject:          mutation_subject,
      mutation_results: mutation_results
    )
  end

  let(:mutation_subject) { double('Subject') }

  describe '#continue?' do
    subject { object.continue? }

    context 'when mutation results are empty' do
      let(:mutation_results) { [] }

      it { should be(true) }
    end

    context 'with failing mutation result' do
      let(:mutation_results) { [double('Mutation Result', success?: false)] }

      it { should be(false) }
    end

    context 'with successful mutation result' do
      let(:mutation_results) { [double('Mutation Result', success?: true)] }

      it { should be(true) }
    end

    context 'with failed and successful mutation result' do
      let(:mutation_results) do
        [
          double('Mutation Result', success?: true),
          double('Mutation Result', success?: false)
        ]
      end

      it { should be(false) }
    end
  end
end
