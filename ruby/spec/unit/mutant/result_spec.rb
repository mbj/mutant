# frozen_string_literal: true

RSpec.describe Mutant::Result do
  let(:object) do
    Class.new do
      include Mutant::Result, Unparser::Anima.new(:runtime, :killtime)

      def collection
        [[1]]
      end

      sum :length, :collection
    end.new(runtime: 3.0, killtime: 1.0)
  end

  describe '.included' do
    it 'includes mixin to freeze instances' do
      expect(object.frozen?).to be(true)
    end

    it 'it makes DSL methods from Mutant::Result available' do
      expect(object.length).to be(1)
    end
  end
end
