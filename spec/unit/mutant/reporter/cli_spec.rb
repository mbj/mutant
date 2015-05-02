RSpec.describe Mutant::Reporter::CLI do
  setup_shared_context

  let(:object) { described_class.new(output, format) }
  let(:output) { StringIO.new                        }

  let(:tput) do
    double(
      'tput',
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

  let(:progressive_format) do
    described_class::Format::Progressive.new(tty: false)
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

    let(:output) { double('Output', tty?: tty?) }
    let(:tty?)   { true                         }
    let(:ci?)    { false                        }

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
      let(:output) { double('Output') }
      let(:tty?)   { false }

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
        Matcher:         #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
        Integration:     null
        Expect Coverage: 100.00%
        Jobs:            1
        Includes:        []
        Requires:        []
      REPORT
    end

    context 'on framed format' do
      it_reports '[tput-prepare]'
    end
  end

  describe '#progress' do
    subject { object.progress(status) }

    context 'on progressive format' do
      let(:format) { progressive_format }

      context 'with empty scheduler' do
        update(:env_result) { { subject_results: [] } }

        it_reports "(00/02)   0% - killtime: 0.00s runtime: 4.00s overhead: 4.00s\n"
      end

      context 'with last mutation present' do
        update(:env_result) { { subject_results: [subject_a_result] } }

        context 'when mutation is successful' do
          it_reports "(02/02) 100% - killtime: 2.00s runtime: 4.00s overhead: 2.00s\n"
        end

        context 'when mutation is NOT successful' do
          update(:mutation_a_test_result) { { passed: true } }
          it_reports "(01/02)  50% - killtime: 2.00s runtime: 4.00s overhead: 2.00s\n"
        end
      end
    end

    context 'on framed format' do
      context 'with empty scheduler' do
        update(:env_result) { { subject_results: [] } }

        it_reports <<-REPORT
          [tput-restore]Mutant configuration:
          Matcher:         #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
          Integration:     null
          Expect Coverage: 100.00%
          Jobs:            1
          Includes:        []
          Requires:        []
          Subjects:        1
          Mutations:       2
          Kills:           0
          Alive:           0
          Runtime:         4.00s
          Killtime:        0.00s
          Overhead:        Inf%
          Coverage:        0.00%
          Expected:        100.00%
          Active subjects: 0
        REPORT
      end

      context 'with scheduler active on one subject' do
        context 'without progress' do
          update(:status) { { active_jobs: [].to_set } }

          it_reports(<<-REPORT)
            [tput-restore]Mutant configuration:
            Matcher:         #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
            Integration:     null
            Expect Coverage: 100.00%
            Jobs:            1
            Includes:        []
            Requires:        []
            Subjects:        1
            Mutations:       2
            Kills:           2
            Alive:           0
            Runtime:         4.00s
            Killtime:        2.00s
            Overhead:        100.00%
            Coverage:        100.00%
            Expected:        100.00%
            Active subjects: 0
          REPORT
        end

        context 'with progress' do
          update(:status) { { active_jobs: [job_a].to_set } }

          context 'on failure' do
            update(:mutation_a_test_result) { { passed: true } }

            it_reports(<<-REPORT)
              [tput-restore]Mutant configuration:
              Matcher:         #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
              Integration:     null
              Expect Coverage: 100.00%
              Jobs:            1
              Includes:        []
              Requires:        []
              Subjects:        1
              Mutations:       2
              Kills:           1
              Alive:           1
              Runtime:         4.00s
              Killtime:        2.00s
              Overhead:        100.00%
              Coverage:        50.00%
              Expected:        100.00%
              Active Jobs:
              0: evil:subject-a:d27d2
              Active subjects: 1
              subject-a mutations: 2
              F.
              (01/02)  50% - killtime: 2.00s runtime: 2.00s overhead: 0.00s
              - test-a
            REPORT
          end

          context 'on success' do
            it_reports(<<-REPORT)
              [tput-restore]Mutant configuration:
              Matcher:         #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
              Integration:     null
              Expect Coverage: 100.00%
              Jobs:            1
              Includes:        []
              Requires:        []
              Subjects:        1
              Mutations:       2
              Kills:           2
              Alive:           0
              Runtime:         4.00s
              Killtime:        2.00s
              Overhead:        100.00%
              Coverage:        100.00%
              Expected:        100.00%
              Active Jobs:
              0: evil:subject-a:d27d2
              Active subjects: 1
              subject-a mutations: 2
              ..
              (02/02) 100% - killtime: 2.00s runtime: 2.00s overhead: 0.00s
              - test-a
            REPORT
          end
        end
      end
    end

    describe '#report' do
      subject { object.report(status.payload) }

      context 'with full coverage' do
        it_reports(<<-REPORT)
          Mutant configuration:
          Matcher:         #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
          Integration:     null
          Expect Coverage: 100.00%
          Jobs:            1
          Includes:        []
          Requires:        []
          Subjects:        1
          Mutations:       2
          Kills:           2
          Alive:           0
          Runtime:         4.00s
          Killtime:        2.00s
          Overhead:        100.00%
          Coverage:        100.00%
          Expected:        100.00%
        REPORT
      end

      context 'and partial coverage' do
        update(:mutation_a_test_result) { { passed: true } }

        context 'on evil mutation' do
          context 'with a diff' do
            it_reports(<<-REPORT)
              subject-a
              - test-a
              evil:subject-a:d27d2
              @@ -1,2 +1,2 @@
              -true
              +false
              -----------------------
              Mutant configuration:
              Matcher:         #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
              Integration:     null
              Expect Coverage: 100.00%
              Jobs:            1
              Includes:        []
              Requires:        []
              Subjects:        1
              Mutations:       2
              Kills:           1
              Alive:           1
              Runtime:         4.00s
              Killtime:        2.00s
              Overhead:        100.00%
              Coverage:        50.00%
              Expected:        100.00%
            REPORT
          end

          context 'without a diff' do
            let(:mutation_a_node) { s(:true) }

            it_reports(<<-REPORT)
              subject-a
              - test-a
              evil:subject-a:d5318
              Original source:
              true
              Mutated Source:
              true
              BUG: Mutation NOT resulted in exactly one diff hunk. Please report a reproduction!
              -----------------------
              Mutant configuration:
              Matcher:         #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
              Integration:     null
              Expect Coverage: 100.00%
              Jobs:            1
              Includes:        []
              Requires:        []
              Subjects:        1
              Mutations:       2
              Kills:           1
              Alive:           1
              Runtime:         4.00s
              Killtime:        2.00s
              Overhead:        100.00%
              Coverage:        50.00%
              Expected:        100.00%
            REPORT
          end
        end

        context 'on neutral mutation' do
          update(:mutation_a_test_result) { { passed: false } }

          let(:mutation_a) do
            Mutant::Mutation::Neutral.new(subject_a, s(:true))
          end

          it_reports(<<-REPORT)
            subject-a
            - test-a
            neutral:subject-a:d5318
            --- Neutral failure ---
            Original code was inserted unmutated. And the test did NOT PASS.
            Your tests do not pass initially or you found a bug in mutant / unparser.
            Subject AST:
            (true)
            Unparsed Source:
            true
            Test Result:
            - 1 @ runtime: 1.0
              - test-a
            Test Output:
            mutation a test result output
            -----------------------
            neutral:subject-a:d5318
            --- Neutral failure ---
            Original code was inserted unmutated. And the test did NOT PASS.
            Your tests do not pass initially or you found a bug in mutant / unparser.
            Subject AST:
            (true)
            Unparsed Source:
            true
            Test Result:
            - 1 @ runtime: 1.0
              - test-a
            Test Output:
            mutation b test result output
            -----------------------
            Mutant configuration:
            Matcher:         #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
            Integration:     null
            Expect Coverage: 100.00%
            Jobs:            1
            Includes:        []
            Requires:        []
            Subjects:        1
            Mutations:       2
            Kills:           0
            Alive:           2
            Runtime:         4.00s
            Killtime:        2.00s
            Overhead:        100.00%
            Coverage:        0.00%
            Expected:        100.00%
          REPORT
        end

        context 'on noop mutation' do
          update(:mutation_a_test_result) { { passed: false } }

          let(:mutation_a) do
            Mutant::Mutation::Noop.new(subject_a, s(:true))
          end

          it_reports(<<-REPORT)
            subject-a
            - test-a
            noop:subject-a:d5318
            ---- Noop failure -----
            No code was inserted. And the test did NOT PASS.
            This is typically a problem of your specs not passing unmutated.
            Test Result:
            - 1 @ runtime: 1.0
              - test-a
            Test Output:
            mutation a test result output
            -----------------------
            noop:subject-a:d5318
            ---- Noop failure -----
            No code was inserted. And the test did NOT PASS.
            This is typically a problem of your specs not passing unmutated.
            Test Result:
            - 1 @ runtime: 1.0
              - test-a
            Test Output:
            mutation b test result output
            -----------------------
            Mutant configuration:
            Matcher:         #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
            Integration:     null
            Expect Coverage: 100.00%
            Jobs:            1
            Includes:        []
            Requires:        []
            Subjects:        1
            Mutations:       2
            Kills:           0
            Alive:           2
            Runtime:         4.00s
            Killtime:        2.00s
            Overhead:        100.00%
            Coverage:        0.00%
            Expected:        100.00%
          REPORT
        end
      end
    end
  end
end
