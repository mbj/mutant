RSpec.describe Mutant::Util, '.one' do
  let(:first) { instance_double(Object)                          }
  let(:array) { instance_double(Array, one?: true, first: first) }

  it 'returns first element' do
    expect(described_class.one(array)).to be(first)
  end

  it 'fails if the list is empty' do
    expect { described_class.one([]) }
      .to raise_error(described_class::SizeError)
      .with_message('expected size to be exactly 1 but size was 0')
  end

  it 'fails if the list has more than one element' do
    expect { described_class.one([1, 2]) }
      .to raise_error(described_class::SizeError)
      .with_message('expected size to be exactly 1 but size was 2')
  end
end
