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

  describe '#runtime' do
    subject { object.runtime }

    it { should eql(1.0) }
  end

  describe '#success?' do
    subject { object.success? }

    let(:result) { double('result boolean') }

    before do
      expect(mutation.class).to receive(:success?)
        .with(test_result)
        .and_return(result)
    end

    it { should be(result) }
  end
end
