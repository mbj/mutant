# frozen_string_literal: true

RSpec.describe Mutant::World do
  subject do
    Mutant::WORLD
  end

  describe '#inspect' do
    def apply
      subject.inspect
    end

    it 'returns expected value' do
      expect(apply).to eql('#<Mutant::World>')
    end

    it 'is frozen' do
      expect(apply.frozen?).to be(true)
    end

    it 'is idempotent' do
      expect(apply).to be(apply)
    end
  end

  describe '#record' do
    subject do
      super().with(
        recorder: recorder
      )
    end

    def apply
      subject.record(name, &block)
    end

    let(:block)  { -> { result }           }
    let(:name)   { :test_name              }
    let(:result) { instance_double(Object) }

    let(:recorder) do
      instance_double(Mutant::Segment::Recorder)
    end

    before do
      allow(recorder).to receive(:record) do |observed_name, &block|
        expect(observed_name).to be(name)
        block.call
      end
    end

    it 'records segment' do
      expect(apply).to be(result)
    end
  end

  describe '#capture_stdout' do
    def apply
      subject.capture_stdout(command)
    end

    let(:open3)          { class_double(Open3)              }
    let(:stdout)         { instance_double(String, :stdout) }
    let(:subject)        { super().with(open3: open3)       }
    let(:command)        { %w[foo bar baz]                  }

    let(:process_status) do
      instance_double(
        Process::Status,
        success?: success?
      )
    end

    before do
      allow(open3).to receive_messages(capture2: [stdout, process_status])
    end

    context 'when process exists successful' do
      let(:success?) { true }

      it 'returns stdout' do
        expect(apply).to eql(Mutant::Either::Right.new(stdout))
      end
    end

    context 'when process exists unsuccessful' do
      let(:success?) { false }

      it 'returns stdout' do
        expect(apply).to eql(Mutant::Either::Left.new("Command #{command.inspect} failed!"))
      end
    end
  end

  describe '#deadline' do
    def apply
      subject.deadline(allowed_time)
    end

    context 'on nil' do
      let(:allowed_time) { nil }

      it 'returns infinite deadline' do
        expect(apply).to eql(Mutant::Timer::Deadline::None.new)
      end
    end

    context 'on float' do
      let(:allowed_time) { 0.1 }

      it 'returns infinite deadline' do
        expect(apply).to eql(
          Mutant::Timer::Deadline.new(
            timer:        subject.timer,
            allowed_time: allowed_time
          )
        )
      end
    end
  end

  describe '#try_const_get' do
    def apply
      subject.try_const_get(const_name)
    end

    context 'on known const name' do
      let(:const_name) { 'Mutant' }

      it 'returns nil' do
        expect(apply).to be(Mutant)
      end
    end

    context 'on unknown const name' do
      let(:const_name) { 'TestApp::Unknown' }

      it 'returns nil' do
        expect(apply).to be(nil)
      end
    end
  end

  describe '#process_warmup' do
    let(:process) { double(Process) }

    subject { super().with(process: process) }

    def apply
      subject.process_warmup
    end

    before do
      allow(process).to receive_messages(
        respond_to?: respond_to?,
        warmup:      process
      )
    end

    context 'when process supports warmup' do
      let(:respond_to?) { true }

      it 'performs warmup' do
        apply

        expect(process).to have_received(:respond_to?).with(:warmup).ordered
        expect(process).to have_received(:warmup).ordered
      end
    end

    context 'when process supports warmup' do
      let(:respond_to?) { false }

      it 'performs warmup' do
        apply

        expect(process).to have_received(:respond_to?).with(:warmup)
        expect(process).to_not have_received(:warmup)
      end
    end
  end
end
