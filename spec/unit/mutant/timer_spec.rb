# frozen_string_literal: true

RSpec.describe Mutant::Timer do
  let(:object) { described_class.new(process) }

  let(:events) { [] }

  let(:times) { [1.0, 2.0] }

  let(:process) { class_double(Process) }

  before do
    allow(process).to receive(:clock_gettime) do |argument|
      expect(argument).to be(Process::CLOCK_MONOTONIC)

      events << :clock_gettime

      times.fetch(events.count(:clock_gettime).pred)
    end
  end

  describe '.now' do
    def apply
      object.now
    end

    it 'returns current monotonic time' do
      expect(apply).to be(1.0)
      expect(apply).to be(2.0)
    end

    it 'calls expected system API' do
      expect { apply }
        .to change(events, :to_a)
        .from([])
        .to(%i[clock_gettime])
    end
  end
end
