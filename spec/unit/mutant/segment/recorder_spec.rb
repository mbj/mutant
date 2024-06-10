# frozen_string_literal: true

RSpec.describe Mutant::Segment::Recorder do
  subject do
    described_class.new(
      gen_id:,
      parent_id:       root_segment.id,
      recording_start: 0.5,
      root_id:         root_segment.id,
      segments:        [root_segment],
      timer:
    )
  end

  let(:gen_id) { -> { @id += 1 } }
  let(:io)     { StringIO.new }

  let(:timer) do
    instance_double(Mutant::Timer).tap do |timer|
      allow(timer).to receive(:now) do
        @timer += 1
      end
    end
  end

  let(:root_segment) do
    Mutant::Segment.new(
      id:              0,
      name:            'root',
      parent_id:       nil,
      timestamp_end:   nil,
      timestamp_start: 0.5
    )
  end

  before do
    @id    = 0
    @timer = 0
  end

  describe '#print_profile' do
    def apply
      add_segments

      subject.print_profile(io)
    end

    shared_examples 'expected report' do
      it 'returns expected report' do
        apply

        io.rewind

        expect(io.read).to eql(expected_report)
      end
    end

    context 'just root segment' do
      def add_segments; end

      let(:expected_report) do
        <<~'REPORT'
          0.0000: (0.5000s)  root
        REPORT
      end

      include_examples 'expected report'
    end

    context 'root with a child' do
      def add_segments
        subject.record(:child0) do
          subject.record(:child1) do
          end

          subject.record(:child2) do
          end
        end
      end

      let(:expected_report) do
        <<~'REPORT'
          0.0000: (6.5000s)  root
          0.5000: (5.0000s)    child0
          1.5000: (1.0000s)      child1
          3.5000: (1.0000s)      child2
          5.5000: (5.0000s)    child0
          6.5000: (6.5000s)  root
        REPORT
      end

      include_examples 'expected report'
    end
  end
end
