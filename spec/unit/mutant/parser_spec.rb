RSpec.describe Mutant::Parser do
  let(:object) { described_class.new }

  describe '#call' do
    let(:path) { instance_double(Pathname) }

    subject { object.call(path) }

    before do
      expect(path).to receive(:read)
        .with(no_args)
        .and_return(':source')
    end

    it 'returns parsed source' do
      expect(subject).to eql(s(:sym, :source))
    end

    it 'is idempotent' do
      source = object.call(path)
      expect(subject).to be(source)
    end
  end
end
