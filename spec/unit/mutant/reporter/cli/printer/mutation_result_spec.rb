# frozen_string_literal: true

RSpec.describe Mutant::Reporter::CLI::Printer::MutationResult do
  setup_shared_context

  let(:reportable) { mutation_a_result }

  describe '.call' do
    context 'isolation problem' do
      let(:status) do
        instance_double(Process::Status)
      end

      let(:mutation_a_isolation_result) do
        Mutant::Isolation::Fork::ChildError.new(status)
      end

      it_reports(<<~'REPORT')
        evil:subject-a:d27d2
        @@ -1,2 +1,2 @@
        -true
        +false
        Killfork exited nonzero. Its result (if any) was ignored:
        #<InstanceDouble(Process::Status) (anonymous)>
        -----------------------
      REPORT
    end

    context 'unsucessful result' do
      with(:mutation_a_test_result) { { passed: true } }

      context 'on evil mutation' do
        context 'with a diff' do
          context 'on a tty' do
            before do
              allow(output).to receive(:tty?).and_return(true)
            end

            it_reports(
              [
                [Mutant::Color::NONE,  "evil:subject-a:d27d2\n"],
                [Mutant::Color::NONE,  "@@ -1,2 +1,2 @@\n"],
                [Mutant::Color::RED,   "-true\n"],
                [Mutant::Color::GREEN, "+false\n"],
                [Mutant::Color::NONE,  "-----------------------\n"]
              ].map { |color, text| color.format(text) }.join
            )
          end

          context 'on non tty' do
            it_reports(<<~'STR')
              evil:subject-a:d27d2
              @@ -1,2 +1,2 @@
              -true
              +false
              -----------------------
            STR
          end
        end

        context 'without a diff' do
          # This is intentionally invalid AST mutant might produce
          let(:subject_a_node) { s(:lvar, :super) }

          # Unparses exactly the same way as above node
          let(:mutation_a_node) { s(:zsuper) }

          it_reports(<<~REPORT)
            evil:subject-a:a5bc7
            --- Internal failure ---
            BUG: A generted mutation did not result in exactly one diff hunk!
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
      end

      context 'on neutral mutation' do
        with(:mutation_a_test_result) { { passed: false } }

        let(:mutation_a) do
          Mutant::Mutation::Neutral.new(subject_a, s(:true))
        end

        it_reports(<<~REPORT)
          neutral:subject-a:d5318
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

      context 'on noop mutation' do
        with(:mutation_a_test_result) { { passed: false } }

        let(:mutation_a) do
          Mutant::Mutation::Noop.new(subject_a, s(:true))
        end

        it_reports(<<~REPORT)
          noop:subject-a:d5318
          ---- Noop failure -----
          No code was inserted. And the test did NOT PASS.
          This is typically a problem of your specs not passing unmutated.
          -----------------------
        REPORT
      end
    end
  end
end
