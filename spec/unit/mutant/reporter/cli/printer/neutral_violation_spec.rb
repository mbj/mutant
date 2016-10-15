RSpec.describe Mutant::Reporter::CLI::Printer::NeutralViolation do
  extend CompressHelper

  setup_shared_context

  let(:reportable) { env_result }

  describe '.call' do
    let(:mutation_a) { Mutant::Mutation::Neutral.new(subject_a, mutation_a_node) }

    neutral_failures = <<-'NEUTRAL'
      subject-a
      - test-a
      neutral:subject-a:d27d2
      --- Neutral failure ---
      Original code was inserted unmutated. And the test did NOT PASS.
      Your tests do not pass initially or you found a bug in mutant / unparser.
      Subject AST:
      s(:true)
      Unparsed Source:
      false
      Test Result:
      - 1 @ runtime: 1.0
        - test-a
      Test Output:
      mutation a test result output
      -----------------------
      neutral:subject-a:d27d2
      --- Neutral failure ---
      Original code was inserted unmutated. And the test did NOT PASS.
      Your tests do not pass initially or you found a bug in mutant / unparser.
      Subject AST:
      s(:true)
      Unparsed Source:
      false
      Test Result:
      - 1 @ runtime: 1.0
        - test-a
      Test Output:
      mutation b test result output
      -----------------------
    NEUTRAL

    message =
      strip_indent(neutral_failures) +
      'Mutant exited early due to neutral failures encountered during execution. Mutant ran '   \
      'your tests using semantically equivalent source code and the tests did not pass. This '  \
      'might happen if your tests are not passing, if executing your test suite mutates global '\
      "state, or if your tests otherwise do not run properly in parallel.\n"

    it_reports(message)
  end
end
