# The effect of this private module is done at boot time.
# Hence there is no way to kill the mutations at runtime
# so we have to directly hook into the private moduel via
# reflection to redo a runtime observable interaction with
# it.
#
# Until mutant gets boot time mutation support there is no
# way to to avoid this.
RSpec.describe 'Mutant::Result::ClassMethods' do
  let(:infected_class) do
    Class.new do
      include Adamantium::Flat, Concord::Public.new(:collection)
      extend Mutant::Result.const_get(:ClassMethods)

      sum :length, :collection
    end
  end

  describe '#sum' do
    let(:object) { infected_class.new(collection) }

    def apply
      object.length
    end

    subject { apply }

    before do
      # memoization behavior
      expect(collection).to receive(:map)
        .once
        .and_call_original

      apply
    end

    context 'empty collection' do
      let(:collection) { [] }

      it { should be(0) }
    end

    context 'non-emtpy collection' do
      let(:collection) { [[1], [2, 3]] }

      it { should be(3) }
    end
  end
end
