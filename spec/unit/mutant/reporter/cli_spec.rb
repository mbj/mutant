RSpec.describe Mutant::Reporter::CLI do
  setup_shared_context

  let(:object) { described_class.new(output, format) }

  let(:tput) do
    instance_double(
      Mutant::Reporter::CLI::Tput,
      restore: '[tput-restore]',
      prepare: '[tput-prepare]'
    )
  end

  let(:framed_format) do
    described_class::Format::Framed.new(
      tty:  false,
      tput: tput
    )
  end

  let(:tty?) { false }

  let(:progressive_format) do
    described_class::Format::Progressive.new(tty: tty?)
  end

  let(:format) { framed_format }

  def contents
    output.rewind
    output.read
  end

  def self.it_reports(expected_content)
    it 'writes expected report to output' do
      expect(subject).to be(object)
      expect(contents).to eql(strip_indent(expected_content))
    end
  end

  before do
    allow(Time).to receive(:now).and_return(Time.now)
  end

  describe '.build' do
    subject { described_class.build(output) }

    let(:progressive_format) do
      described_class::Format::Progressive.new(tty: tty?)
    end

    let(:framed_format) do
      described_class::Format::Framed.new(
        tty:  true,
        tput: tput
      )
    end

    before do
      expect(ENV).to receive(:key?).with('CI').and_return(ci?)
    end

    let(:output) { instance_double(IO, tty?: tty?) }
    let(:tty?)   { true                            }
    let(:ci?)    { false                           }

    context 'when not on CI and on a tty' do
      before do
        expect(described_class::Tput).to receive(:detect).and_return(tput)
      end

      context 'and tput is available' do
        it { should eql(described_class.new(output, framed_format)) }
      end

      context 'and tput is not available' do
        let(:tput) { nil }

        it { should eql(described_class.new(output, progressive_format)) }
      end
    end

    context 'when on CI' do
      let(:ci?) { true }
      it { should eql(described_class.new(output, progressive_format)) }
    end

    context 'when output is not a tty?' do
      let(:tty?) { false }
      it { should eql(described_class.new(output, progressive_format)) }
    end

    context 'when output does not respond to #tty?' do
      let(:output) { instance_double(IO) }
      let(:tty?)   { false               }

      it { should eql(described_class.new(output, progressive_format)) }
    end
  end

  describe '#warn' do
    subject { object.warn(message) }

    let(:message) { 'message' }

    it_reports("message\n")
  end

  describe '#delay' do
    subject { object.delay }

    it { should eql(0.05) }
  end

  describe '#start' do
    subject { object.start(env) }

    context 'on progressive format' do
      let(:format) { progressive_format }

      it_reports(<<-REPORT)
        Mutant configuration:
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     Mutant::Integration::Null
        Jobs:            1
        Includes:        []
        Requires:        []
      REPORT
    end

    context 'on framed format' do
      it_reports '[tput-prepare]'
    end
  end

  describe '#report' do
    subject { object.report(env_result) }

    it_reports(<<-REPORT)
      Mutant configuration:
      Matcher:         #<Mutant::Matcher::Config empty>
      Integration:     Mutant::Integration::Null
      Jobs:            1
      Includes:        []
      Requires:        []
      Subjects:        1
      Mutations:       2
      Results:         2
      Kills:           2
      Alive:           0
      Runtime:         4.00s
      Killtime:        2.00s
      Overhead:        100.00%
      Mutations/s:     0.50
      Coverage:        100.00%
    REPORT
  end

  describe '#progress' do
    subject { object.progress(status) }

    context 'on framed format' do
      let(:format) { framed_format }

      it_reports(<<-REPORT)
        [tput-restore]Mutant configuration:
        Matcher:         #<Mutant::Matcher::Config empty>
        Integration:     Mutant::Integration::Null
        Jobs:            1
        Includes:        []
        Requires:        []
        Subjects:        1
        Mutations:       2
        Results:         2
        Kills:           2
        Alive:           0
        Runtime:         4.00s
        Killtime:        2.00s
        Overhead:        100.00%
        Mutations/s:     0.50
        Coverage:        100.00%
        Active subjects: 0
      REPORT
    end

    context 'on progressive format' do
      let(:format) { progressive_format }

      context 'with empty scheduler' do
        with(:env_result) { { subject_results: [] } }

        let(:tty?) { true }

        it_reports Mutant::Color::GREEN.format('(00/02) 100% - killtime: 0.00s runtime: 4.00s overhead: 4.00s') << "\n"
      end

      context 'with last mutation present' do
        with(:env_result) { { subject_results: [subject_a_result] } }

        context 'when mutation is successful' do
          it_reports "(02/02) 100% - killtime: 2.00s runtime: 4.00s overhead: 2.00s\n"
        end

        context 'when mutation is NOT successful' do
          with(:mutation_a_test_result) { { passed: true } }

          it_reports "(01/02)  50% - killtime: 2.00s runtime: 4.00s overhead: 2.00s\n"
        end
      end
    end
  end
end
