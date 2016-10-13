RSpec.describe Mutant::Result::Mutation do
  let(:object) do
    described_class.new(
      mutation:    mutation,
      test_result: test_result
    )
  end

  let(:mutation) { instance_double(Mutant::Mutation) }

  let(:test_result) do
    instance_double(
      Mutant::Result::Test,
      runtime: 1.0
    )
  end

  shared_context 'mutation test result success' do
    before do
      expect(mutation.class)
        .to receive(:success?)
        .with(test_result)
        .and_return(result)
    end
  end

  describe '#runtime' do
    subject { object.runtime }

    it { should eql(1.0) }
  end

  describe '#success?' do
    subject { object.success? }

    let(:result) { double('result boolean') }

    it { should be(result) }

    include_context 'mutation test result success'
  end

  describe '#neutral_failure?' do
    subject { object.neutral_failure? }

    let(:result) { false }

    before do
      expect(mutation).to receive_messages(neutral?: neutral_mutation)
    end

    context 'when given an unsuccessful evil mutation' do
      let(:neutral_mutation) { false }

      it { should be(false) }
    end

    context 'when given an unsuccessful neutral mutation' do
      let(:neutral_mutation) { true }

      it { should be(true) }
    end

    include_context 'mutation test result success'
  end
end
