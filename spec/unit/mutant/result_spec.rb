RSpec.describe Mutant::Result do
  describe '.included' do
    let(:object) do
      Class.new do
        include Mutant::Result

        def collection
          [[1]]
        end

        sum :length, :collection
      end.new
    end

    it 'includes mixin to freeze instances' do
      expect(object.frozen?).to be(true)
    end

    it 'it makes DSL methods from Mutant::Result available' do
      expect(object.length).to be(1)
    end
  end
end
