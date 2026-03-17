# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::SubjectResult do
  setup_shared_context

  let(:reportable) { subject_a_result }

  describe '.call' do
    context 'on full coverage' do
      it_reports <<~'STR'
        subject-a
        - test-a
      STR
    end

    context 'on partial coverage' do
      with(:mutation_a_criteria_result) { { test_result: false } }

      it_reports <<~'STR'
        subject-a
        - test-a
        evil:subject-a:d27d2
        -----------------------
        @@ -1 +1 @@
        -true
        +false
        -----------------------
      STR
    end

    context 'on partial coverage on a tty' do
      with(:mutation_a_criteria_result) { { test_result: false } }

      before do
        allow(output).to receive(:tty?).and_return(true)
      end

      it_reports(
        [
          [Unparser::Color::RED,   'subject-a'],
          [Unparser::Color::NONE,  "\n- test-a\nevil:subject-a:d27d2\n-----------------------\n"],
          [Unparser::Color::NONE,  "@@ -1 +1 @@\n"],
          [Unparser::Color::RED,   "-true\n"],
          [Unparser::Color::GREEN, "+false\n"],
          [Unparser::Color::NONE,  "-----------------------\n"]
        ].map { |color, text| color.format(text) }.join
      )
    end

    context 'on partial coverage with process status' do
      with(:mutation_a_criteria_result) { { test_result: false } }

      with(:mutation_a_isolation_result) do
        {
          process_status: Mutant::Result::ProcessStatus.new(exitstatus: 0)
        }
      end

      it_reports <<~'STR'
        subject-a
        - test-a
        evil:subject-a:d27d2
        -----------------------
        Killfork: #<Mutant::Result::ProcessStatus exitstatus=0>
        @@ -1 +1 @@
        -true
        +false
        -----------------------
      STR
    end

    context 'on partial coverage without a diff' do
      with(:mutation_a_criteria_result) { { test_result: false } }

      # This is intentionally invalid AST mutant might produce
      let(:subject_a_node) { s(:lvar, :super) }

      # Unparses exactly the same way as above node
      let(:mutation_a_node) { s(:zsuper) }

      it_reports(<<~REPORT)
        subject-a
        - test-a
        evil:subject-a:a5bc7
        -----------------------
        --- Internal failure ---
        BUG: A generated mutation did not result in exactly one diff hunk!
        This is an invariant violation by the mutation generation engine.
        Please report a reproduction to https://github.com/mbj/mutant
        Original unparsed source:
        super
        Original AST:
        s(:lvar, :super)
        Mutated unparsed source:
        super
        Mutated AST:
        s(:zsuper)
        -----------------------
      REPORT
    end

    context 'on neutral mutation failure' do
      with(:mutation_a_test_result) { { passed: false } }
      with(:mutation_a_criteria_result) { { test_result: false } }

      let(:mutation_a) do
        Mutant::Mutation::Neutral.from_node(subject: subject_a, node: s(:true)).from_right
      end

      it_reports(<<~REPORT)
        subject-a
        - test-a
        neutral:subject-a:d5318
        -----------------------
        --- Neutral failure ---
        Original code was inserted unmutated. And the test did NOT PASS.
        Your tests do not pass initially or you found a bug in mutant / unparser.
        Subject AST:
        s(:true)
        Unparsed Source:
        true
        -----------------------
      REPORT
    end

    context 'on noop mutation failure' do
      with(:mutation_a_test_result) { { passed: false } }
      with(:mutation_a_criteria_result) { { test_result: false } }

      let(:mutation_a) do
        Mutant::Mutation::Noop.from_node(subject: subject_a, node: s(:true)).from_right
      end

      it_reports(<<~REPORT)
        subject-a
        - test-a
        noop:subject-a:d5318
        -----------------------
        ---- Noop failure -----
        No code was inserted. And the test did NOT PASS.
        This is typically a problem of your specs not passing unmutated.
        -----------------------
      REPORT
    end

    context 'without results' do
      with(:subject_a_result) { { coverage_results: [] } }

      it_reports <<~'STR'
        subject-a
        - test-a
      STR
    end
  end
end
