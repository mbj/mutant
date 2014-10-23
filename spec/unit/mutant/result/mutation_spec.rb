RSpec.describe Mutant::Result::Mutation do
  let(:object) do
    described_class.new(
      index: 0,
      mutation: double('mutation'),
      test_results: double('test results')
    )
  end

  describe '#continue?' do
    subject { object.continue? }

    it 'forwards calls to mutation' do
      return_value = double('return value')
      expect(object.mutation.class).to receive(:continue?).with(object.test_results).and_return(return_value)
      expect(subject).to be(return_value)
    end
  end
end
