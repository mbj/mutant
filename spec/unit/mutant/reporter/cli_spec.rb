RSpec.describe Mutant::Reporter::CLI do
  let(:object) { described_class.new(output, format) }
  let(:output) { StringIO.new }

  let(:framed_format) do
    described_class::Format::Framed.new(
      tty:  false,
      tput: described_class::Tput::UNAVAILABLE
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
      subject
      expect(contents).to eql(strip_indent(expected_content))
    end
  end

  before do
    allow(Time).to receive(:now).and_return(Time.now)
  end

  let(:result) do
    Mutant::Result::Env.new(
      done:            true,
      env:             env,
      runtime:         1.1,
      subject_results: subject_results
    )
  end

  let(:env) do
    double(
      'Env',
      class: Mutant::Env,
      matchable_scopes: matchable_scopes,
      config: config,
      subjects: subjects,
      mutations: subjects.flat_map(&:mutations)
    )
  end

  let(:config)           { Mutant::Config::DEFAULT.update(processes: 1) }
  let(:mutation_class)   { Mutant::Mutation::Evil                       }
  let(:matchable_scopes) { double('Matchable Scopes', length: 10)       }

  before do
    allow(mutation_a).to receive(:subject).and_return(_subject)
    allow(mutation_b).to receive(:subject).and_return(_subject)
  end

  let(:mutation_a) do
    double(
      'Mutation',
      identification:  'mutation_id-a',
      class:           mutation_class,
      original_source: 'true',
      source:          mutation_source
    )
  end

  let(:mutation_b) do
    double(
      'Mutation',
      identification:  'mutation_id-b',
      class:           mutation_class,
      original_source: 'true',
      source:          mutation_source
    )
  end

  let(:mutation_source) { 'false' }

  let(:_subject) do
    double(
      'Subject',
      class:          Mutant::Subject,
      node:           s(:true),
      identification: 'subject_id',
      mutations:      subject_mutations,
      tests: [
        double('Test', identification: 'test_id')
      ]
    )
  end

  let(:subject_mutations) { [mutation_a] }

  let(:test_results) do
    [
      double(
        'Test Result',
        class: Mutant::Result::Test,
        test: _subject.tests.first,
        runtime: 1.0,
        output: 'test-output',
        success?: mutation_result_success
      )
    ]
  end

  let(:mutation_a_result) do
    double(
      'Mutation Result',
      class: Mutant::Result::Mutation,
      mutation: mutation_a,
      killtime: 0.5,
      runtime:  1.0,
      index:    0,
      success?: mutation_result_success,
      test_results: test_results,
      failed_test_results: mutation_result_success ? [] : test_results
    )
  end

  let(:subject_results) do
    [
      Mutant::Result::Subject.new(
        subject: _subject,
        runtime: 1.0,
        mutation_results: [mutation_a_result]
      )
    ]
  end

  let(:subjects) { [_subject] }

  describe '.build' do
    subject { described_class.build(output) }

    let(:progressive_format) do
      described_class::Format::Progressive.new(tty: tty?)
    end

    let(:framed_format) do
      described_class::Format::Framed.new(
        tty:  true,
        tput: described_class::Tput::INSTANCE
      )
    end

    before do
      expect(ENV).to receive(:key?).with('CI').and_return(ci?)
    end

    let(:output) { double('Output', tty?: tty?) }
    let(:tty?)   { true                         }
    let(:ci?)    { false                        }

    context 'when not on CI and on a tty' do
      it { should eql(described_class.new(output, framed_format)) }
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

  describe '#start' do
    subject { object.start(env) }

    context 'on progressive format' do
      let(:format) { progressive_format }

      it_reports(<<-REPORT)
        Mutant configuration:
        Matcher:            #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
        Integration:        null
        Expect Coverage:    100.00%
        Processes:          1
        Includes:           []
        Requires:           []
      REPORT
    end

    context 'on framed format' do
      it_reports ''
    end
  end

  describe '#progress' do
    subject { object.progress(collector) }

    let(:collector) do
      Mutant::Runner::Collector.new(env)
    end

    let(:mutation_result_success) { true }

    context 'on progressive format' do

      let(:format) { progressive_format }

      context 'with empty collector' do

        it_reports ''
      end

      context 'with last mutation present' do

        before do
          collector.start(mutation_a)
          collector.finish(mutation_a_result)
        end

        context 'when mutation is successful' do
          it_reports '.'
        end

        context 'when mutation is NOT successful' do
          let(:mutation_result_success) { false }

          it_reports 'F'
        end
      end
    end

    context 'on framed format' do

      let(:mutation_result_success) { true }

      context 'with empty collector' do
        it_reports <<-REPORT
          Mutant configuration:
          Matcher:            #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
          Integration:        null
          Expect Coverage:    100.00%
          Processes:          1
          Includes:           []
          Requires:           []
          Available Subjects: 1
          Subjects:           1
          Mutations:          1
          Kills:              0
          Alive:              0
          Runtime:            0.00s
          Killtime:           0.00s
          Overhead:           NaN%
          Coverage:           0.00%
          Expected:           100.00%
          Active subjects:    0
        REPORT
      end

      context 'with collector active on one subject' do
        before do
          collector.start(mutation_a)
        end

        context 'without progress' do

          it_reports(<<-REPORT)
            Mutant configuration:
            Matcher:            #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
            Integration:        null
            Expect Coverage:    100.00%
            Processes:          1
            Includes:           []
            Requires:           []
            Available Subjects: 1
            Subjects:           1
            Mutations:          1
            Kills:              0
            Alive:              0
            Runtime:            0.00s
            Killtime:           0.00s
            Overhead:           NaN%
            Coverage:           0.00%
            Expected:           100.00%
            Active subjects:    1
            subject_id mutations: 1
            - test_id
            (00/01)   0% - killtime: 0.00s runtime: 0.00s overhead: 0.00s
          REPORT
        end

        context 'with progress' do

          let(:subject_mutations) { [mutation_a, mutation_b] }

          before do
            collector.start(mutation_b)
            collector.finish(mutation_a_result)
          end

          context 'on failure' do
            let(:mutation_result_success) { false }

            it_reports(<<-REPORT)
              Mutant configuration:
              Matcher:            #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
              Integration:        null
              Expect Coverage:    100.00%
              Processes:          1
              Includes:           []
              Requires:           []
              Available Subjects: 1
              Subjects:           1
              Mutations:          2
              Kills:              0
              Alive:              1
              Runtime:            0.00s
              Killtime:           0.50s
              Overhead:           -100.00%
              Coverage:           0.00%
              Expected:           100.00%
              Active subjects:    1
              subject_id mutations: 2
              - test_id
              F
              (00/02)   0% - killtime: 0.50s runtime: 1.00s overhead: 0.50s
            REPORT
          end

          context 'on success' do
            it_reports(<<-REPORT)
              Mutant configuration:
              Matcher:            #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
              Integration:        null
              Expect Coverage:    100.00%
              Processes:          1
              Includes:           []
              Requires:           []
              Available Subjects: 1
              Subjects:           1
              Mutations:          2
              Kills:              1
              Alive:              0
              Runtime:            0.00s
              Killtime:           0.50s
              Overhead:           -100.00%
              Coverage:           100.00%
              Expected:           100.00%
              Active subjects:    1
              subject_id mutations: 2
              - test_id
              .
              (01/02) 100% - killtime: 0.50s runtime: 1.00s overhead: 0.50s
            REPORT
          end
        end
      end
    end

    describe '#report' do
      subject { object.report(result) }

      context 'with full coverage' do
        let(:mutation_result_success) { true }

        it_reports(<<-REPORT)
          Mutant configuration:
          Matcher:            #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
          Integration:        null
          Expect Coverage:    100.00%
          Processes:          1
          Includes:           []
          Requires:           []
          Available Subjects: 1
          Subjects:           1
          Mutations:          1
          Kills:              1
          Alive:              0
          Runtime:            1.10s
          Killtime:           0.50s
          Overhead:           120.00%
          Coverage:           100.00%
          Expected:           100.00%
        REPORT
      end

      context 'and partial coverage' do
        let(:mutation_result_success) { false }

        context 'on evil mutation' do
          context 'with a diff' do
            it_reports(<<-REPORT)
              subject_id
              - test_id
              mutation_id-a
              @@ -1,2 +1,2 @@
              -true
              +false
              -----------------------
              Mutant configuration:
              Matcher:            #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
              Integration:        null
              Expect Coverage:    100.00%
              Processes:          1
              Includes:           []
              Requires:           []
              Available Subjects: 1
              Subjects:           1
              Mutations:          1
              Kills:              0
              Alive:              1
              Runtime:            1.10s
              Killtime:           0.50s
              Overhead:           120.00%
              Coverage:           0.00%
              Expected:           100.00%
            REPORT
          end

          context 'without a diff' do
            let(:mutation_source) { 'true' }

            it_reports(<<-REPORT)
              subject_id
              - test_id
              mutation_id-a
              Original source:
              true
              Mutated Source:
              true
              BUG: Mutation NOT resulted in exactly one diff. Please report a reproduction!
              -----------------------
              Mutant configuration:
              Matcher:            #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
              Integration:        null
              Expect Coverage:    100.00%
              Processes:          1
              Includes:           []
              Requires:           []
              Available Subjects: 1
              Subjects:           1
              Mutations:          1
              Kills:              0
              Alive:              1
              Runtime:            1.10s
              Killtime:           0.50s
              Overhead:           120.00%
              Coverage:           0.00%
              Expected:           100.00%
            REPORT
          end
        end

        context 'on neutral mutation' do
          let(:mutation_class)  { Mutant::Mutation::Neutral }
          let(:mutation_source) { 'true' }

          it_reports(<<-REPORT)
            subject_id
            - test_id
            mutation_id-a
            --- Neutral failure ---
            Original code was inserted unmutated. And the test did NOT PASS.
            Your tests do not pass initially or you found a bug in mutant / unparser.
            Subject AST:
            (true)
            Unparsed Source:
            true
            Test Reports: 1
            - test_id / runtime: 1.0
            Test Output:
            test-output
            -----------------------
            Mutant configuration:
            Matcher:            #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
            Integration:        null
            Expect Coverage:    100.00%
            Processes:          1
            Includes:           []
            Requires:           []
            Available Subjects: 1
            Subjects:           1
            Mutations:          1
            Kills:              0
            Alive:              1
            Runtime:            1.10s
            Killtime:           0.50s
            Overhead:           120.00%
            Coverage:           0.00%
            Expected:           100.00%
          REPORT
        end

        context 'on noop mutation' do
          let(:mutation_class) { Mutant::Mutation::Noop }

          it_reports(<<-REPORT)
            subject_id
            - test_id
            mutation_id-a
            ---- Noop failure -----
            No code was inserted. And the test did NOT PASS.
            This is typically a problem of your specs not passing unmutated.
            Test Reports: 1
            - test_id / runtime: 1.0
            Test Output:
            test-output
            -----------------------
            Mutant configuration:
            Matcher:            #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
            Integration:        null
            Expect Coverage:    100.00%
            Processes:          1
            Includes:           []
            Requires:           []
            Available Subjects: 1
            Subjects:           1
            Mutations:          1
            Kills:              0
            Alive:              1
            Runtime:            1.10s
            Killtime:           0.50s
            Overhead:           120.00%
            Coverage:           0.00%
            Expected:           100.00%
          REPORT
        end
      end

      context 'without subjects' do
        let(:subjects)        { [] }
        let(:subject_results) { [] }

        let(:config) { Mutant::Config::DEFAULT.update(processes: 1, includes: %w[include-dir], requires: %w[require-name]) }

        it_reports(<<-REPORT)
          Mutant configuration:
          Matcher:            #<Mutant::Matcher::Config match_expressions=[] subject_ignores=[] subject_selects=[]>
          Integration:        null
          Expect Coverage:    100.00%
          Processes:          1
          Includes:           ["include-dir"]
          Requires:           ["require-name"]
          Available Subjects: 0
          Subjects:           0
          Mutations:          0
          Kills:              0
          Alive:              0
          Runtime:            1.10s
          Killtime:           0.00s
          Overhead:           Inf%
          Coverage:           0.00%
          Expected:           100.00%
        REPORT
      end
    end
  end
end
