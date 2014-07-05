require 'spec_helper'

describe Mutant::Reporter::CLI do
  let(:object) { described_class.new(output) }
  let(:output) { StringIO.new }

  def contents
    output.rewind
    output.read
  end

  describe '#warn' do
    subject { object.warn(message) }

    let(:message) { 'message' }

    it 'writes message to output' do
      expect { subject }.to change { contents }.from('').to("message\n")
    end
  end

  describe '#report' do
    subject { object.report(result) }

    let(:result) do
      Mutant::Result::Env.new(
        env:             env,
        runtime:         1.1,
        subject_results: subject_results
      )
    end

    let(:config)          { Mutant::Config::DEFAULT }
    let(:mutation_class)  { Mutant::Mutation::Evil }
    let(:env)             { double('Env', config: config, subjects: subjects) }

    before do
      allow(mutation).to receive(:subject).and_return(_subject)
    end

    let(:mutation) do
      double(
        'Mutation',
        identification:  'mutation_id',
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
        mutations:      [mutation],
        tests: [
          double('Test', identification: 'test_id')
        ]
      )
    end

    let(:subject_results) do
      [
        Mutant::Result::Subject.new(
          subject: _subject,
          runtime: 1.0,
          mutation_results: [
            double(
              'Mutation Result',
              class: Mutant::Result::Mutation,
              mutation: mutation,
              killtime: 0.5,
              success?: mutation_result_success
            )
          ]
        )
      ]
    end

    context 'with subjects' do

      let(:subjects) { [_subject] }

      context 'and full covergage' do
        let(:mutation_result_success) { true }

        it 'writes report to output' do
          subject
          expect(contents).to eql(strip_indent(<<-REPORT))
            Subjects:  1
            Mutations: 1
            Kills:     1
            Alive:     0
            Runtime:   1.10s
            Killtime:  0.50s
            Overhead:  120.00%
            Coverage:  100.00%
            Expected:  100.00%
          REPORT
        end
      end

      context 'and partial covergage' do
        let(:mutation_result_success) { false }

        context 'on evil mutation' do
          context 'with a diff' do
            it 'writes report to output' do
              subject
              expect(contents).to eql(strip_indent(<<-REPORT))
                subject_id
                - test_id
                mutation_id
                @@ -1,2 +1,2 @@
                -true
                +false
                Subjects:  1
                Mutations: 1
                Kills:     0
                Alive:     1
                Runtime:   1.10s
                Killtime:  0.50s
                Overhead:  120.00%
                Coverage:  0.00%
                Expected:  100.00%
              REPORT
            end
          end

          context 'without a diff' do
            let(:mutation_source) { 'true' }

            it 'writes report to output' do
              subject
              expect(contents).to eql(strip_indent(<<-REPORT))
                subject_id
                - test_id
                mutation_id
                BUG: Mutation NOT resulted in exactly one diff. Please report a reproduction!
                Subjects:  1
                Mutations: 1
                Kills:     0
                Alive:     1
                Runtime:   1.10s
                Killtime:  0.50s
                Overhead:  120.00%
                Coverage:  0.00%
                Expected:  100.00%
              REPORT
            end
          end
        end

        context 'on neutral mutation' do
          let(:mutation_class)  { Mutant::Mutation::Neutral }
          let(:mutation_source) { 'true' }

          it 'writes report to output' do
            subject
            expect(contents).to eql(strip_indent(<<-REPORT))
              subject_id
              - test_id
              mutation_id
              --- Neutral failure ---
              Original code was inserted unmutated. And the test did NOT PASS.
              Your tests do not pass initially or you found a bug in mutant / unparser.
              Subject AST:
              (true)
              Unparsed Source:
              true
              -----------------------
              Subjects:  1
              Mutations: 1
              Kills:     0
              Alive:     1
              Runtime:   1.10s
              Killtime:  0.50s
              Overhead:  120.00%
              Coverage:  0.00%
              Expected:  100.00%
            REPORT
          end
        end

        context 'on neutral mutation' do
          let(:mutation_class) { Mutant::Mutation::Noop }

          it 'writes report to output' do
            subject
            expect(contents).to eql(strip_indent(<<-REPORT))
              subject_id
              - test_id
              mutation_id
              --- Noop failure ---
              No code was inserted. And the test did NOT PASS.
              This is typically a problem of your specs not passing unmutated.
              --------------------
              Subjects:  1
              Mutations: 1
              Kills:     0
              Alive:     1
              Runtime:   1.10s
              Killtime:  0.50s
              Overhead:  120.00%
              Coverage:  0.00%
              Expected:  100.00%
            REPORT
          end
        end
      end
    end

    context 'without subjects' do

      let(:subjects)        { [] }
      let(:subject_results) { [] }

      it 'writes report to output' do
        subject
        expect(contents).to eql(strip_indent(<<-REPORT))
          Subjects:  0
          Mutations: 0
          Kills:     0
          Alive:     0
          Runtime:   1.10s
          Killtime:  0.00s
          Overhead:  Inf%
          Coverage:  0.00%
          Expected:  100.00%
        REPORT
      end
    end
  end
end
