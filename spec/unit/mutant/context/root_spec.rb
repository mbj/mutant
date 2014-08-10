RSpec.describe Mutant::Context, '#root' do
  subject { object.root }

  let(:object) { described_class.allocate }

  it 'should raise error' do
    expect do
      subject
    end.to raise_error('Mutant::Context#root is not implemented')
  end
end
