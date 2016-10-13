RSpec.describe Mutant::FailurePredicate do
  let(:object)         { class_with_predicate.new(success_object) }
  let(:success_object) { double(:negatable, '!': failure_object)  }
  let(:failure_object) { double(:negation)                        }

  let(:class_with_predicate) do
    Class.new do
      include Mutant::FailurePredicate

      def initialize(value)
        @value = value
      end

      def success?
        @value
      end
    end
  end

  it 'provides success object' do
    expect(object.failure?).to be(failure_object)
  end
end
