# frozen_string_literal: true

RSpec.describe Mutant::Meta::Example::Verification do
  let(:object)          { described_class.from_mutations(example:, mutations:) }
  let(:original_source) { 'true' }

  let(:location) do
    instance_double(
      Thread::Backtrace::Location,
      path: 'foo.rb',
      to_s: '<location>'
    )
  end

  let(:example) do
    Mutant::Meta::Example.new(
      expected:,
      location:,
      lvars:           [],
      node:            s(:true),
      operators:       Mutant::Mutation::Operators::Full.new,
      original_source:,
      types:           [:true]
    )
  end

  let(:mutations) do
    generated_nodes.map do |node|
      Mutant::Mutation::Evil.from_node(subject: example, node:)
    end
  end

  let(:generated_nodes) { [] }
  let(:expected)        { [] }

  def make_expected(input)
    Mutant::Meta::Example::Expected.new(
      node:            Unparser.parse(input),
      original_source: input
    )
  end

  context 'when generated nodes equal expected nodes' do
    it 'returns success' do
      expect(object.success?).to be(true)
    end

    it 'returns empty error report' do
      expect(object.error_report).to eql(<<~'REPORT'.chomp)
        <location>
        Original: (operators: full)
        (true)
        true
      REPORT
    end
  end

  shared_examples_for 'failure' do
    it 'returns failure' do
      expect(object.success?).to be(false)
    end

    it 'returns expected error report' do
      expect(object.error_report).to eql(expected_report)
    end
  end

  context 'when original source fails the unparser validation' do
    let(:expected_report) do
      <<~REPORT.chomp
        <location>
        Original: (operators: full)
        (true)
        true
        [original] report
        [original] lines
      REPORT
    end

    let(:validation) do
      instance_double(Unparser::Validation, success?: false, report: "report\nlines")
    end

    before do
      allow(Unparser::Validation).to receive_messages(from_string: validation)
    end

    include_examples 'failure'
  end

  context 'when expected node is missing' do
    let(:expected)        { [make_expected('false'), make_expected('nil')] }
    let(:generated_nodes) { [s(:false)]                                    }

    let(:expected_report) do
      <<~'REPORT'.chomp
        <location>
        Original: (operators: full)
        (true)
        true
        Missing mutations:
        s(:nil)
        nil
      REPORT
    end

    include_examples 'failure'

    it 'records correct missing' do
      expect(object.__send__(:missing)).to eql(
        [
          Mutant::Mutation::Evil.new(node: s(:nil), subject: example, source: 'nil')
        ]
      )
    end
  end

  context 'when there is unexpected generated node' do
    let(:expected)        { [make_expected('false')] }
    let(:generated_nodes) { [s(:false), s(:nil)] }

    let(:expected_report) do
      <<~'REPORT'.chomp
        <location>
        Original: (operators: full)
        (true)
        true
        Unexpected mutations:
        s(:nil)
        nil
      REPORT
    end

    include_examples 'failure'
  end

  context 'when mutation generates is no diff to original source' do
    let(:expected)        { [make_expected('true')] }
    let(:generated_nodes) { [s(:true)]              }

    let(:expected_report) do
      <<~'REPORT'.chomp
        <location>
        Original: (operators: full)
        (true)
        true
        No-Diff mutations:
        s(:true)
        true
      REPORT
    end

    include_examples 'failure'
  end

  context 'when the generated mutation is invalid' do
    let(:invalid_node) do
      s(:op_asgn, s(:send, s(:self), :at, s(:int, 1)), :+, s(:int, 1))
    end

    let(:generated_nodes) { [invalid_node] }
    let(:expected)        { []             }

    let(:expected_report) do
      <<~REPORT.chomp
        <location>
        Original: (operators: full)
        (true)
        true
        [invalid-mutation] report
        [invalid-mutation] lines
      REPORT
    end

    let(:validation) do
      instance_double(Unparser::Validation, success?: false, report: "report\nlines")
    end

    before do
      allow(Mutant::Mutation).to receive_messages(from_node: left(validation))
    end

    include_examples 'failure'

    it 'generates validation with expected node' do
      expect(object.success?).to be(false)

      expect(Mutant::Mutation).to have_received(:from_node).with(
        node:    invalid_node,
        subject: example
      )
    end
  end
end
