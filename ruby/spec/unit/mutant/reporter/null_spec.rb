# frozen_string_literal: true

RSpec.describe Mutant::Reporter::Null do
  let(:object) { described_class.new     }
  let(:value)  { instance_double(Object) }

  %i[progress report start warn].each do |name|
    describe "##{name}" do
      subject { object.public_send(name, value) }

      it_should_behave_like 'a command method'
    end
  end
end
