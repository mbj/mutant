RSpec.describe Mutant::Trace do
  let(:object) { described_class }

  test_a_line = __LINE__ + 2
  def test_a
    test_b
  end

  test_b_line = __LINE__ + 2
  def test_b
    __method__
  end

  test_c_line = __LINE__ + 2
  def test_c
  end

  shared_examples_for 'line trace' do
    it 'returns correct trace results' do
      expect(subject.cover?(__FILE__, test_a_line)).to be(true)
      expect(subject.cover?(__FILE__, test_b_line)).to be(true)
      expect(subject.cover?(__FILE__, test_c_line)).to be(false)
      expect(subject.cover?(__FILE__, __LINE__)).to be(false)
      expect(subject.cover?('/dev/null', test_a_line)).to be(false)
    end
  end

  describe '.call' do
    subject { object.call { test_a } }

    let(:expected_trace) do
      described_class.send(
        :new,
        :test_b,
        {
          __FILE__ => [29, 6, 11, 12, 7].to_set,
        }
      )
    end

    it { should eql(expected_trace) }
  end
end
