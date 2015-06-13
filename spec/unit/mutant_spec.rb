RSpec.describe Mutant do
  let(:object) { described_class }

  describe '.ci?' do
    subject { object.ci? }

    let(:result) { double('Result') }

    before do
      expect(ENV).to receive(:key?).with('CI').and_return(result)
    end

    it { should be(result) }
  end
end
