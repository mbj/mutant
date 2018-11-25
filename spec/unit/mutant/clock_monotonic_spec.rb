# frozen_string_literal: true

RSpec.describe Mutant::Timer do
  let(:events) { [] }

  let(:times) { [1.0, 2.0] }

  before do
    allow(Process).to receive(:clock_gettime) do |argument|
      expect(argument).to be(Process::CLOCK_MONOTONIC)

      events << :clock_gettime

      times.fetch(events.count(:clock_gettime).pred)
    end
  end

  describe '.elapsed' do
    def apply
      described_class.elapsed { events << :yield }
    end

    it 'executes events in expected sequence' do
      expect { apply }
        .to change(events, :to_a)
        .from([])
        .to(%i[clock_gettime yield clock_gettime])
    end

    it 'returns elapsed time' do
      expect(apply).to be(1.0)
    end
  end

  describe '.now' do
    def apply
      described_class.now
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
