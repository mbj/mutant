RSpec.describe Mutant::Cache do
  let(:object) { described_class.new }

  describe '#parse' do
    let(:path) { double('Path') }

    subject { object.parse(path) }

    before do
      allow(File).to receive(:read).with(path).and_return(':source')
    end

    it 'returns parsed source' do
      expect(subject).to eql(s(:sym, :source))
    end

    it 'returns cached parsed source' do
      source = object.parse(path)
      expect(subject).to be(source)
    end
  end
end
