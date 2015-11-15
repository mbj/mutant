RSpec.describe Mutant::Result::Subject do
  let(:object) do
    described_class.new(
      subject:          mutation_subject,
      mutation_results: mutation_results,
      tests:            []
    )
  end

  let(:mutation_subject) { instance_double(Mutant::Subject) }

  describe '#continue?' do
    subject { object.continue? }

    context 'when mutation results are empty' do
      let(:mutation_results) { [] }

      it { should be(true) }
    end

    context 'with failing mutation result' do
      let(:mutation_results) { [instance_double(Mutant::Result::Mutation, success?: false)] }

      it { should be(false) }
    end

    context 'with successful mutation result' do
      let(:mutation_results) { [instance_double(Mutant::Result::Mutation, success?: true)] }

      it { should be(true) }
    end

    context 'with failed and successful mutation result' do
      let(:mutation_results) do
        [
          instance_double(Mutant::Result::Mutation, success?: true),
          instance_double(Mutant::Result::Mutation, success?: false)
        ]
      end

      it { should be(false) }
    end
  end
end
