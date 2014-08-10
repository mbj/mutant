RSpec.describe Mutant::Matcher::Null do
  let(:object) { described_class.new }

  describe '#each' do
    let(:yields) { [] }

    subject { object.each { |entry| yields << entry } }

    # it_should_behave_like 'an #each method'
    context 'with no block' do
      subject { object.each }

      it { should be_instance_of(to_enum.class) }

      it 'yields the expected values' do
        expect(subject.to_a).to eql(object.to_a)
      end
    end

    it 'should yield subjects' do
      expect { subject }.not_to change { yields }.from([])
    end
  end
end
