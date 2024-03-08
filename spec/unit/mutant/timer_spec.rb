# frozen_string_literal: true

RSpec.describe Mutant::Timer do
  let(:events)  { []                                    }
  let(:object)  { described_class.new(process: process) }
  let(:process) { class_double(Process)                 }
  let(:times)   { [0.5, 2.0]                            }

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
      expect(apply).to be(0.5)
      expect(apply).to be(2.0)
    end

    it 'calls expected system API' do
      expect { apply }
        .to change(events, :to_a)
        .from([])
        .to(%i[clock_gettime])
    end
  end

  describe '#elapsed' do
    let(:executions) { [] }

    def apply
      object.elapsed do
        executions << nil
      end
    end

    it 'executes the block' do
      expect { apply }.to change { executions }.from([]).to([nil])
    end

    it 'returns execution time' do
      expect(apply).to eql(1.5)
    end
  end
end
